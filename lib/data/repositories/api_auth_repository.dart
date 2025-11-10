import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  ApiAuthRepository({
    required this.dioClient,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dioClient.post(
      '/auth/login/',
      data: {
        'email': email,
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    
    // Check if login was successful
    final success = responseData['success'];
    if (success == false) {
      final errorMessage = responseData['message'] ?? 'Login failed';
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        errorCode: 'LOGIN_FAILED',
        data: responseData,
      );
    }
    
    // Extract data from the response structure: { success, message, data }
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    
    // Store tokens securely (supports {access,refresh}, {accessToken,refreshToken}, {token}, or nested {tokens:{...}})
    final Map<String, dynamic> tokens =
        (data['tokens'] is Map<String, dynamic>) ? (data['tokens'] as Map<String, dynamic>) : data;

    if (tokens['access'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['access']);
    }
    if (tokens['refresh'] is String) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refresh']);
    }
    if (tokens['accessToken'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['accessToken']);
    }
    if (tokens['refreshToken'] is String) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refreshToken']);
    }
    if (tokens['token'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['token']);
    }

    // Return the full response for the cubit to extract user info
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    String? phoneNumber,
    String? username,
    String? patronymic,
    required String gender,
  }) async {
    final response = await dioClient.post(
      ApiConfig.authRegister,
      data: {
        'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        'email': email,
        'password': password,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone': phoneNumber,
        if (username != null && username.isNotEmpty) 'username': username,
        if (patronymic != null && patronymic.isNotEmpty) 'patronymic': patronymic,
        'gender': gender,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    
    // Check if registration was successful
    final success = responseData['success'];
    if (success == false) {
      final errorMessage = responseData['message'] ?? 'Registration failed';
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        errorCode: 'REGISTRATION_FAILED',
        data: responseData,
      );
    }
    
    // Extract data from the response structure: { success, message, data }
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    
    // Store tokens securely (supports {access,refresh}, {accessToken,refreshToken}, {token}, or nested {tokens:{...}})
    final Map<String, dynamic> tokens =
        (data['tokens'] is Map<String, dynamic>) ? (data['tokens'] as Map<String, dynamic>) : data;

    if (tokens['access'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['access']);
    }
    if (tokens['refresh'] is String) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refresh']);
    }
    if (tokens['accessToken'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['accessToken']);
    }
    if (tokens['refreshToken'] is String) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refreshToken']);
    }
    if (tokens['token'] is String) {
      await secureStorage.write(key: 'access_token', value: tokens['token']);
    }

    return responseData;
  }

  @override
  Future<void> logout() async {
    try {
      // Call logout endpoint if available
      await dioClient.post(ApiConfig.authLogout);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear local tokens
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
    }
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await dioClient.post(
      ApiConfig.authRefresh,
      data: {
        'refresh': refreshToken,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    
    // Extract data from the response structure
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    
    // Update stored tokens
    final Map<String, dynamic> tokens =
        (data['tokens'] is Map<String, dynamic>) ? (data['tokens'] as Map<String, dynamic>) : data;

    if (tokens.containsKey('access')) {
      await secureStorage.write(key: 'access_token', value: tokens['access']);
    }
    if (tokens.containsKey('refresh')) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refresh']);
    }

    // Also handle alternative token names
    if (tokens.containsKey('accessToken')) {
      await secureStorage.write(key: 'access_token', value: tokens['accessToken']);
    }
    if (tokens.containsKey('refreshToken')) {
      await secureStorage.write(key: 'refresh_token', value: tokens['refreshToken']);
    }
    if (tokens.containsKey('token')) {
      await secureStorage.write(key: 'access_token', value: tokens['token']);
    }

    return responseData;
  }

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    return accessToken != null && accessToken.isNotEmpty;
  }
}

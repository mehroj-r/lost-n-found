import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Function(String refreshToken)? onTokenRefresh;

  ApiInterceptor({
    required this.secureStorage,
    this.onTokenRefresh,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    final isAuthEndpoint = options.path.contains('/auth/login/') ||
                          options.path.contains('/auth/register/') ||
                          options.path.contains('/auth/refresh/');
    
    // Add authorization token to requests (except login/register)
    if (!isAuthEndpoint) {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      
      if (refreshToken != null && onTokenRefresh != null) {
        try {
          // Attempt to refresh token
          await onTokenRefresh!(refreshToken);

          // Retry the original request with new token
          final accessToken = await secureStorage.read(key: 'access_token');
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Token refresh failed, clear tokens
          await secureStorage.delete(key: 'access_token');
          await secureStorage.delete(key: 'refresh_token');
          return handler.reject(err);
        }
      }
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    super.onResponse(response, handler);
  }
}

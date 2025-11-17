import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Function(String refreshToken)? onTokenRefresh;
  final Function()? onUnauthorized; // New callback for logout

  ApiInterceptor({
    required this.secureStorage,
    this.onTokenRefresh,
    this.onUnauthorized,
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
    final statusCode = err.response?.statusCode;
    
    // Handle 403 Forbidden - immediate logout
    if (statusCode == 403) {
      await _handleUnauthorizedAccess();
      return handler.reject(err);
    }
    
    // Handle 401 Unauthorized - try to refresh token
    if (statusCode == 401) {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      
      if (refreshToken != null && onTokenRefresh != null) {
        try {
          // Attempt to refresh token
          await onTokenRefresh!(refreshToken);

          // Retry the original request with new token
          final accessToken = await secureStorage.read(key: 'access_token');
          if (accessToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

            final response = await Dio().fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Token refresh failed, logout user
          await _handleUnauthorizedAccess();
          return handler.reject(err);
        }
      } else {
        // No refresh token available, logout user
        await _handleUnauthorizedAccess();
        return handler.reject(err);
      }
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    super.onResponse(response, handler);
  }

  Future<void> _handleUnauthorizedAccess() async {
    // Clear tokens
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    
    // Trigger logout callback
    onUnauthorized?.call();
  }
}

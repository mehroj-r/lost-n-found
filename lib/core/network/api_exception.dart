import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: null,
          errorCode: 'TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request timeout. Please try again.',
          statusCode: null,
          errorCode: 'TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Response timeout. Server is taking too long to respond.',
          statusCode: null,
          errorCode: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: null,
          errorCode: 'CANCELLED',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: null,
          errorCode: 'NO_CONNECTION',
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate error. Connection is not secure.',
          statusCode: null,
          errorCode: 'SSL_ERROR',
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          statusCode: null,
          errorCode: 'UNKNOWN',
        );
    }
  }

  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message;
    String? errorCode;

    switch (statusCode) {
      case 400:
        message = _extractErrorMessage(data, 'Bad request. Please check your input.');
        errorCode = 'BAD_REQUEST';
        break;
      case 401:
        message = _extractErrorMessage(data, 'Unauthorized. Please login again.');
        errorCode = 'UNAUTHORIZED';
        break;
      case 403:
        message = _extractErrorMessage(data, 'Access forbidden. You don\'t have permission.');
        errorCode = 'FORBIDDEN';
        break;
      case 404:
        message = _extractErrorMessage(data, 'Resource not found.');
        errorCode = 'NOT_FOUND';
        break;
      case 409:
        message = _extractErrorMessage(data, 'Conflict. Resource already exists.');
        errorCode = 'CONFLICT';
        break;
      case 422:
        message = _extractErrorMessage(data, 'Validation error. Please check your input.');
        errorCode = 'VALIDATION_ERROR';
        break;
      case 429:
        message = _extractErrorMessage(data, 'Too many requests. Please try again later.');
        errorCode = 'RATE_LIMIT';
        break;
      case 500:
        message = _extractErrorMessage(data, 'Server error. Please try again later.');
        errorCode = 'SERVER_ERROR';
        break;
      case 502:
        message = _extractErrorMessage(data, 'Bad gateway. Service temporarily unavailable.');
        errorCode = 'BAD_GATEWAY';
        break;
      case 503:
        message = _extractErrorMessage(data, 'Service unavailable. Please try again later.');
        errorCode = 'SERVICE_UNAVAILABLE';
        break;
      default:
        message = _extractErrorMessage(data, 'Server error occurred.');
        errorCode = 'SERVER_ERROR';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      data: data,
    );
  }

  static String _extractErrorMessage(dynamic data, String defaultMessage) {
    if (data == null) return defaultMessage;

    if (data is Map<String, dynamic>) {
      // Try common error message keys
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is String) return error;
        if (error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
      }
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('msg')) return data['msg'].toString();
    }

    return defaultMessage;
  }

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';

/// Error Interceptor
///
/// Centralized error handling for API responses.
/// Transforms Dio exceptions into user-friendly error messages.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An unexpected error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'Bad request. Please check your input.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 403:
            errorMessage = 'Forbidden. You don\'t have permission.';
            break;
          case 404:
            errorMessage = 'Resource not found.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage =
                err.response?.data?['message'] ?? 'An error occurred';
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled.';
        break;

      case DioExceptionType.unknown:
        errorMessage = 'No internet connection. Please check your network.';
        break;

      default:
        errorMessage = err.message ?? 'An unexpected error occurred';
    }

    // Create a custom error with user-friendly message
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    super.onError(customError, handler);
  }
}

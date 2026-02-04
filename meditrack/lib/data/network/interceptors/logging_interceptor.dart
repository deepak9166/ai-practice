import 'package:dio/dio.dart';
import '../../../config/app_config.dart';
import '../../../log/app_logs.dart';

/// Logging Interceptor
///
/// Logs all HTTP requests and responses for debugging purposes.
/// Only logs in development and staging environments.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.isDevelopment || AppConfig.isStaging) {
      appLog('┌─────────────────────────────────────────────────────────────');
      appLog('│ REQUEST: ${options.method} ${options.uri}');
      appLog('│ Headers: ${options.headers}');
      if (options.data != null) {
        appLog('│ Body: ${options.data}');
      }
      appLog('└─────────────────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.isDevelopment || AppConfig.isStaging) {
      appLog('┌─────────────────────────────────────────────────────────────');
      appLog(
        '│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      );
      appLog('│ Data: ${response.data}');
      appLog('└─────────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.isDevelopment || AppConfig.isStaging) {
      appLog('┌─────────────────────────────────────────────────────────────');
      appLog('│ ERROR: ${err.type}');
      appLog('│ Message: ${err.message}');
      appLog('│ Response: ${err.response?.data}');
      appLog('└─────────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }
}

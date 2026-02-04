import 'package:dio/dio.dart';

/// Auth Interceptor
///
/// Automatically adds authentication token to request headers.
/// Handles token refresh logic if needed.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get token from storage (you can use SharedPreferences or secure storage)
    // For now, using a placeholder - implement actual storage retrieval
    final token = _getAuthToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 unauthorized errors - refresh token or logout
    if (err.response?.statusCode == 401) {
      // Implement token refresh or logout logic here
      _handleUnauthorized();
    }

    super.onError(err, handler);
  }

  /// Get authentication token from storage
  String? _getAuthToken() {
    // Example: return SharedPreferences.getInstance().then((prefs) => prefs.getString(AppConstants.authTokenKey));
    return null;
  }

  /// Handle unauthorized access
  void _handleUnauthorized() {
    // Clear tokens and navigate to login
    // Implement logout logic
  }
}

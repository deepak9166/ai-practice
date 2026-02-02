/// API Endpoints Constants
///
/// Centralized location for all API endpoint paths.
/// This ensures consistency and makes it easy to update endpoints.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints
  static const String signIn = '/auth/signin';
  static const String signUp = '/auth/signup';
  static const String signOut = '/auth/signout';
  static const String refreshToken = '/auth/refresh';
}

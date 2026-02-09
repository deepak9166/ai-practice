import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import '../../../config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../log/app_logs.dart';
import '../dto/request/auth/sign_in/sign_in_request.dart';
import '../dto/response/auth/sign_in/sign_in_response.dart';
import '../dto/request/auth/sign_up/sign_up_request.dart';
import '../dto/response/auth/sign_up/sign_up_response.dart';
import '../../../core/service/api_service.dart';

/// Auth Repository
///
/// Repository pattern implementation for authentication operations.
/// Acts as a bridge between the data layer (API service) and the domain layer.
/// Handles API calls and data transformation.
class AuthRepository {
  AuthRepository(this._apiService);

  final ApiService _apiService;
  final LocalAuthentication auth = LocalAuthentication();

  /// Sign in user
  ///
  /// [request] - Sign in request model containing email and password
  /// Returns [SignInResponse] on success
  /// Throws [DioException] on failure
  Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      appLog("AppConfig.isDummy : --- ${AppConfig.isUseDummyApi}");
      if (AppConfig.isUseDummyApi) {
        return AuthDummyRepository.signIn(request);
      }
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.signIn,
        data: request.toJson(),
      );

      return SignInResponse.fromJson(response.data!);
    } on DioException {
      // Re-throw with additional context if needed
      rethrow;
    }
  }

  /// Sign up new user
  ///
  /// [request] - Sign up request model containing name, email, and password
  /// Returns [SignUpResponse] on success
  /// Throws [DioException] on failure
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      if (AppConfig.isUseDummyApi) {
        return AuthDummyRepository.signUp(request);
      }
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.signUp,
        data: request.toJson(),
      );

      return SignUpResponse.fromJson(response.data!);
    } on DioException {
      // Re-throw with additional context if needed
      rethrow;
    }
  }

  Future<bool> checkBiomatric() async {
    final availableBiometrics = await auth.isDeviceSupported();
    return availableBiometrics;
  }

  Future availableBioMatrics() async {
    final List<BiometricType> availableBiometrics = await auth
        .getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
      appLog('SOME BIOMETRICS FOUND');
    } else {
      appLog('SOME BIOMETRICS NOT FOUND');
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }

    //    final bool didAuthenticate = await auth.authenticate(
    //   localizedReason: 'Please authenticate to show account balance',
    //   authMessages: const <AuthMessages>[
    //     AndroidAuthMessages(
    //       signInTitle: 'Oops! Biometric authentication required!',
    //       cancelButton: 'No thanks',
    //     ),
    //     IOSAuthMessages(cancelButton: 'No thanks'),
    //   ],
    // );
  }

  /// Sign out user
  ///
  /// Clears authentication tokens and logs out the user
  Future<void> signOut() async {
    try {
      await _apiService.post(ApiEndpoints.signOut);
      // Clear local tokens here
    } on DioException {
      // Even if API call fails, clear local tokens
      rethrow;
    }
  }
}

class AuthDummyRepository {
  static Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      var response = SignInResponse(
        refreshToken: "abc",
        token: "abc",
        user: UserData(id: "1", name: "Deepak", email: request.email),
      );

      return response;
    } on DioException {
      // Re-throw with additional context if needed
      rethrow;
    }
  }

  static Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      var response = SignUpResponse(
        refreshToken: "abc",
        token: "abc",
        user: UserData(id: "1", name: "Deepak", email: request.email),
      );

      return response;
    } on DioException {
      // Re-throw with additional context if needed
      rethrow;
    }
  }
}

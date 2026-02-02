import 'package:flutter/material.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/log/error_handler.dart';
import 'package:meditrack/presentation/providers/local_storage_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/network/dto/request/auth/sign_in/sign_in_request.dart';
import '../../../../data/network/repositories/auth_repository.dart';
import '../../../../data/network/services/social_login_service.dart';
import '../../base/base_view_model.dart';

/// Sign In ViewModel
///
/// Manages the state and business logic for the Sign In screen.
/// Extends BaseViewModel to inherit common state management functionality.
class SignInViewModel extends BaseViewModel {
  SignInViewModel(
    this._authRepository,
    this.authStateNotifierProvider,
    this.googleAuthService,
    this.facebookAuthService,
  );

  final AuthRepository _authRepository;
  final AuthStateNotifier authStateNotifierProvider;
  final GoogleAuthService googleAuthService;
  final FacebookAuthService facebookAuthService;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TextEditingController get phoneNumber => _emailController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  ValueNotifier<bool> isMobileLogin = ValueNotifier(true);
  ValueNotifier<bool> isBioMatricAvailable = ValueNotifier(false);

  /// Sign in user
  ///
  /// Validates the form and calls the repository to sign in the user.
  /// Navigates to home screen on success.
  Future<void> signIn(BuildContext context) async {
    appLog("called sign function");

    final request = SignInRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await executeWithLoading(() async {
      await _authRepository.signIn(request);

      // Save tokens (implement actual storage)
      // await _saveTokens(response.token, response.refreshToken);
      await authStateNotifierProvider.login(
        'accessToken_${_emailController.text}',
      );
      // Navigate to home
      if (context.mounted) {
        AppRouter.go(context, AppConstants.routeLanding);
      }
    });
  }

  Future<void> checkAvailableLocks() async {
    appLog("called verifyFaceLock function");
    var locks = await _authRepository.availableBioMatrics();
    appLog('locks $locks');
  }

  Future<void> googleLogin({
    required ValueChanged<String> onSuccess,
    required ValueChanged<String> onFail,
  }) async {
    try {
      var reuslt = await googleAuthService.signIn();
      onSuccess.call("On Success");
    } catch (e) {
      var errorMessage = parseException(e);
      onFail(errorMessage.errorMessage);
    }
  }

  Future<void> facebookLogin({
    required ValueChanged<String> onSuccess,
    required ValueChanged<String> onFail,
  }) async {
    try {
      var reuslt = await facebookAuthService.signIn();
      onSuccess.call("On Success");
    } catch (e) {
      print(e);
      var errorMessage = parseException(e);
      onFail(errorMessage.errorMessage);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> checkBiomatricAvailablity() async {
    var status = await _authRepository.checkBiomatric();
    checkAvailableLocks();
    isBioMatricAvailable.value = status;
  }
}

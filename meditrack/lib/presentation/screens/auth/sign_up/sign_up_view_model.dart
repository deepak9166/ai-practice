import 'package:flutter/material.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/network/dto/request/auth/sign_up/sign_up_request.dart';
import '../../../../data/network/repositories/auth_repository.dart';
import '../../base/base_view_model.dart';

/// Sign Up ViewModel
///
/// Manages the state and business logic for the Sign Up screen.
/// Extends BaseViewModel to inherit common state management functionality.
class SignUpViewModel extends BaseViewModel {
  SignUpViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  /// Sign up new user
  ///
  /// Validates the form and calls the repository to sign up the user.
  /// Navigates to home screen on success.
  Future<void> signUp(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    final request = SignUpRequest(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await executeWithLoading(
      () async {
       var result =  await _authRepository.signUp(request);
       appLog(result);

        // Save tokens (implement actual storage)
        // await _saveTokens(response.token, response.refreshToken);

        // Navigate to home
        if (context.mounted) {
          AppRouter.push(context, AppConstants.routeSignUpVerify);
        }
      },
      errorCallBack:  (error, stackError) {
        context.showError("$error");
      },
    );
  }

  /// Verify
  Future<void> signUpVerify(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    final request = SignUpRequest(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await executeWithLoading(
      () async {
       var result =  await _authRepository.signUp(request);
       appLog(result);

        // Save tokens (implement actual storage)
        // await _saveTokens(response.token, response.refreshToken);

        // Navigate to home
        if (context.mounted) {
          AppRouter.go(context, AppConstants.routeSignUpSuccess);
        }
      },
      errorCallBack:  (error, stackError) {
        context.showError("$error");
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}


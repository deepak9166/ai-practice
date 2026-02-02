import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/extension/toast_helper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/network/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../base/base_view_model.dart';

/// Sign Up ViewModel
///
/// Manages the state and business logic for the Sign Up screen.
/// Extends BaseViewModel to inherit common state management functionality.
class ForgotPasswordViewModel extends BaseViewModel {
  ForgotPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController passwordController = TextEditingController();

  /// Sign up new user
  ///
  /// Validates the form and calls the repository to sign up the user.
  /// Navigates to home screen on success.
  Future<void> forgotPassword(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    await executeWithLoading(
      () async {
        //  var result =  await _authRepository.signUp(request);
        //  appLog(result);

        // Save tokens (implement actual storage)
        // await _saveTokens(response.token, response.refreshToken);

        // Navigate to home
        if (context.mounted) {
          AppRouter.push(context, AppConstants.routeSignUpVerify);
        }
      },
      errorCallBack: (error, stackError) {
        context.showError("$error");
      },
    );
  }

  /// Verify
  Future<void> forgtoPasswordVerify({required ValueChanged<String> onSuccess,required ValueChanged<String> onError}) async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    await executeWithLoading(
      () async {
        //  var result =  await _authRepository.signUp(request);
        //  appLog(result);

        // Save tokens (implement actual storage)
        // await _saveTokens(response.token, response.refreshToken);

        // Navigate to home
      onSuccess("SUccess");
      },
      errorCallBack: (error, stackError) {
        onError("$error");
        // context.showError("$error");
      },
    );
  }

}

/// Sign Up ViewModel Provider
final signUpViewModelProvider = Provider.autoDispose<ForgotPasswordViewModel>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordViewModel(authRepository);
});

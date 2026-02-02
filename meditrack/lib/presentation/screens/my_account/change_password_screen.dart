import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state_aware.dart';

import '../../../core/constants/language_keys.dart';
import '../../../core/utils/validators.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_input_field.dart';
import '../../common_widgets/spacing_widgets.dart';
import '../../providers/vm_provider.dart';
import '../base/screen_state.dart';
import 'view_model/my_account_view_model.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends BaseConsumerState<ChangePasswordScreen, MyAccountViewModel> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _isCurrentPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> _isNewPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> _isConfirmPasswordVisible = ValueNotifier(false);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isCurrentPasswordVisible.dispose();
    _isNewPasswordVisible.dispose();
    _isConfirmPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LanguageKeys.changePassword.tr()),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isCurrentPasswordVisible,
                        builder: (context, isVisible, child) {
                          return CustomInputField(
                            controller: _currentPasswordController,
                            label: LanguageKeys.enterOldPassword.tr(),
                            hint: LanguageKeys.enterOldPassword.tr(),
                            obscureText: !isVisible,
                            suffixIcon: InkWell(
                              onTap: () {
                                _isCurrentPasswordVisible.value = !isVisible;
                              },
                              child: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            validator: Validators.validatePassword,
                          );
                        },
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<bool>(
                        valueListenable: _isNewPasswordVisible,
                        builder: (context, isVisible, child) {
                          return CustomInputField(
                            controller: _newPasswordController,
                            label: LanguageKeys.enterNewPassword.tr(),
                            hint: LanguageKeys.enterNewPassword.tr(),
                            obscureText: !isVisible,
                            suffixIcon: InkWell(
                              onTap: () {
                                _isNewPasswordVisible.value = !isVisible;
                              },
                              child: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            validator: Validators.validatePassword,
                          );
                        },
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<bool>(
                        valueListenable: _isConfirmPasswordVisible,
                        builder: (context, isVisible, child) {
                          return CustomInputField(
                            controller: _confirmPasswordController,
                            label: LanguageKeys.enterConfirmPassword.tr(),
                            hint: LanguageKeys.enterConfirmPassword.tr(),
                            obscureText: !isVisible,
                            suffixIcon: InkWell(
                              onTap: () {
                                _isConfirmPasswordVisible.value = !isVisible;
                              },
                              child: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return LanguageKeys.passwordsDoNotMatch.tr();
                              }
                              return Validators.validatePassword(value);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: ScreenStateAware(
                showApiProgressInPlace: true,
                state: viewModel.screenState,
                builder: (context) => CustomButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    // TODO: Implement change password logic
                    context.pop();
                  },
                  text: LanguageKeys.changePassword.tr(),
                  isLoading:
                      viewModel.screenState.value == ScreenState.apiProgress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  MyAccountViewModel createViewModel() {
    return ref.read(myAccountViewModel);
  }

  @override
  String screenName() {
    return "Change Password Screen";
  }
}

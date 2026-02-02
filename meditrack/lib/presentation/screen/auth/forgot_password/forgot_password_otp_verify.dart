import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';

import '../../../../log/app_logs.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_otp_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../base/base_consumer_state.dart';
import '../../base/screen_state.dart';
import '../../base/screen_state_aware.dart';
import 'forgot_password_view_model.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOtpVerify extends ConsumerStatefulWidget {
  const ForgotPasswordOtpVerify({super.key});

  @override
  ConsumerState<ForgotPasswordOtpVerify> createState() =>
      _ForgotPasswordVerifyState();
}

class _ForgotPasswordVerifyState
    extends BaseConsumerState<ForgotPasswordOtpVerify, ForgotPasswordViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichTextTitle(
                  title1: "Verify ",
                  title2: "Account",
                  description:
                      "A 6 digit code has been sent to your registered Phone Number or Email ID.",
                ),
                VerticalSpacing.extraLarge,

                // OTP VERIFY FIELD
                CustomOTPTextField(
                  label: "OTP",
                  onEntered: (otpValue) {
                    viewModel.forgtoPasswordVerify(onSuccess: _onSuccess, onError: _onFail);
                  },
                ),

                VerticalSpacing.medium,

                VerticalSpacing.large,
                ScreenStateAware(
                  state: viewModel.screenState,
                  showApiProgressInPlace: true,
                  builder: (childContext) {
                    return CustomButton(
                      onPressed: () => viewModel.forgtoPasswordVerify(onSuccess: _onSuccess, onError: _onFail),
                      text: 'Verify',
                      isLoading:
                          viewModel.screenState.value ==
                          ScreenState.apiProgress,
                    );
                  },
                ),
                VerticalSpacing.large,

                // Add Social buttons
                VerticalSpacing.small,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn’t receive code? ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        appLog("Add function for resend otp");
                      },
                      child: Text(
                        'Resend',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                  ],
                ),

                VerticalSpacing.large,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  ForgotPasswordViewModel createViewModel() {
    return ref.read(forgotPasswordVm);
  }

  @override
  String screenName() {
    return "Sign Up Screen";
  }

  void _onSuccess(String value) {
      if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(viewModel: viewModel),));
          
        }
  }

  void _onFail(String value) {

  }
}

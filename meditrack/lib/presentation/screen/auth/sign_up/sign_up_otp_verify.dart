import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/log/app_logs.dart';

import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_otp_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../providers/vm_provider.dart';
import '../../base/base_consumer_state.dart';
import '../../base/screen_state.dart';
import '../../base/screen_state_aware.dart';
import 'sign_up_view_model.dart';

class SignUpVerify extends ConsumerStatefulWidget {
  const SignUpVerify({super.key});

  @override
  ConsumerState<SignUpVerify> createState() => _SignUpVerifyState();
}

class _SignUpVerifyState
    extends BaseConsumerState<SignUpVerify, SignUpViewModel> {
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
                    viewModel.signUpVerify(context);
                  },
                ),

                VerticalSpacing.medium,

                VerticalSpacing.large,
                ScreenStateAware(
                  state: viewModel.screenState,
                  showApiProgressInPlace: true,
                  builder: (childContext) {
                    return CustomButton(
                      onPressed: () => viewModel.signUpVerify(context),
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
  SignUpViewModel createViewModel() {
    return ref.read(signUpVm);
  }

  @override
  String screenName() {
    return "Sign Up Screen";
  }
}

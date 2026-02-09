import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../log/app_logs.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_input_field.dart';
import '../../../common_widgets/custom_phone_number_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/social_round_button.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../providers/vm_provider.dart';
import 'sign_up_view_model.dart';

/// Sign Up Screen
///
/// Registration screen for new users.
/// Follows MVVM pattern with SignUpViewModel managing business logic.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState
    extends BaseConsumerState<SignUpScreen, SignUpViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VerticalSpacing.small,
                RichTextTitle(
                  title1: "Welcome to\n",
                  title2: "Into Fitness",
                  description:
                      "Get started by creating your account & embark on a seamless app experience",
                ),
                VerticalSpacing.extraLarge,

                CustomInputField(
                  controller: viewModel.emailController,
                  label: 'Email ID',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                ),
                VerticalSpacing.medium,

                CustomInputPhoneNumberField(
                  controller: viewModel.phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhoneNumber,
                ),
                VerticalSpacing.medium,
                CustomInputField(
                  controller: viewModel.passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: Validators.validatePassword,
                ),
                VerticalSpacing.medium,
                CustomInputField(
                  controller: viewModel.confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (value) => Validators.validateConfirmPassword(
                    viewModel.passwordController.text,
                    value,
                  ),
                ),

                VerticalSpacing.medium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(
                        width: 0,
                        strokeAlign: 0,
                        color: Colors.transparent,
                      ),
                      tristate: true,
                      visualDensity: VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      value: true,
                      onChanged: (value) {},
                    ),
                    HorizontalSpacing.smallXs,
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                          children: [
                            TextSpan(text: "By registering you accept our "),
                            TextSpan(
                              text: "Terms of Services & Privacy Policy",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                VerticalSpacing.large,
                ScreenStateAware(
                  state: viewModel.screenState,
                  showApiProgressInPlace: true,
                  builder: (childContext) {
                    return CustomButton(
                      onPressed: () => viewModel.signUp(context),
                      text: 'Continue',
                      isLoading:
                          viewModel.screenState.value ==
                          ScreenState.apiProgress,
                    );
                  },
                ),
                VerticalSpacing.large,
                Text("Register with", textAlign: TextAlign.center),
                VerticalSpacing.medium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    SocialRoundButton(path: PngImageId.instagram.path),
                    SocialRoundButton(path: SvgImageId.facebook.path),
                    SocialRoundButton(path: SvgImageId.google.path),
                    SocialRoundButton(path: SvgImageId.apple.path),
                  ],
                ),
                // Add Social buttons
                VerticalSpacing.small,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        appLog("Add function for login");
                        AppRouter.go(context, AppConstants.routeSignIn);
                      },
                      child: Text(
                        'Login',
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

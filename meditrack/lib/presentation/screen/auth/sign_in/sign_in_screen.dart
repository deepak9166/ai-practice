import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/extension/sage_execute_extesion.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/screen/auth/sign_in/biomatric_viewmodel.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import '../../../../config/png_config.dart';
import '../../../../config/svg_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../enum/bio_matric_enum.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_input_field.dart';
import '../../../common_widgets/custom_phone_number_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/social_round_button.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../providers/vm_provider.dart';
import '../../base/screen_state.dart';
import 'sign_in_viewmodel.dart';

/// Sign In Screen
///
/// Authentication screen for user login.
/// Follows MVVM pattern with SignInViewModel managing business logic.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState
    extends BaseConsumerState<SignInScreen, SignInViewModel> {
  final _formKey = GlobalKey<FormState>();

  @override
  void onModelReady(SignInViewModel model) {
    // BIOMATRIC
    model.checkBiomatricAvailablity();
    super.onModelReady(model);
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(biometricProvider);

    ref.listen(biometricProvider, (prev, next) {
      if (next == BiometricStatus.authenticated) {
        AppRouter.go(context, AppConstants.routeLanding);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                VerticalSpacing.small,
                RichTextTitle(
                  title1: "Welcome to\n",
                  title2: "Into Fitness",
                  description:
                      "Get ready to unlock a world of possibilities - log in to your account now!",
                ),
                VerticalSpacing.medium,
                _MobileMailToggle(toggleValue: viewModel.isMobileLogin),

                ValueListenableBuilder(
                  valueListenable: viewModel.isMobileLogin,
                  builder: (context, isMobileLogin, child) {
                    if (isMobileLogin) {
                      return CustomInputPhoneNumberField(
                        controller: viewModel.phoneNumber,
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        // validator: Validators.validatePhoneNumber,
                      );
                    } else {
                      return CustomInputField(
                        controller: viewModel.emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      );
                    }
                  },
                ),

                VerticalSpacing.medium,
                CustomInputField(
                  controller: viewModel.passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                 
                  validator: Validators.validatePassword,
                ),
                VerticalSpacing.smallXs,
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    child: Text(
                      'Forgot password?',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () {
                      appLog("navigate to forgot password");
                      AppRouter.push(context, AppConstants.routeForgotPassword);
                    },
                  ),
                ),
                VerticalSpacing.large,

                ScreenStateAware(
                  showApiProgressInPlace: true,
                  state: viewModel.screenState,
                  builder: (context) => CustomButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      ref.safeExecute(
                        key: "login",
                        action: () => viewModel.signIn(context),
                      );
                    },
                    text: 'LOGIN',
                    isLoading:
                        viewModel.screenState.value == ScreenState.apiProgress,
                  ),
                ),
                VerticalSpacing.large,
                Text(
                  "Register with",
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                VerticalSpacing.large,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    SocialRoundButton(
                      path: PngImageId.instagram.path,
                      onPressed: () {
                        appLog('Insta login');
                      },
                    ),
                    SocialRoundButton(
                      path: SvgImageId.facebook.path,
                      onPressed: () {
                        appLog('Facebook login');
                        ref.safeExecute(
                          key: "facebookLogin",
                          action: () => viewModel.facebookLogin(
                            onSuccess: _onSuccess,
                            onFail: _onFail,
                          ),
                        );
                      },
                    ),
                    SocialRoundButton(
                      path: SvgImageId.google.path,
                      onPressed: () {
                        appLog('Google login');

                        ref.safeExecute(
                          key: "googleLogin",
                          action: () => viewModel.googleLogin(
                            onSuccess: _onSuccess,
                            onFail: _onFail,
                          ),
                        );
                      },
                    ),
                    SocialRoundButton(
                      path: SvgImageId.apple.path,
                      onPressed: () {
                        appLog('Apple login');
                      },
                    ),
                  ],
                ),
                VerticalSpacing.medium,
                ValueListenableBuilder(
                  valueListenable: viewModel.isBioMatricAvailable,
                  builder: (context, isAvailable, child) {
                    if (isAvailable == false) {
                      return SizedBox();
                    }
                    return Column(
                      children: [
                        Text(
                          "Or Continue with",
                          textAlign: TextAlign.center,
                          style: TextTheme.of(context).bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        VerticalSpacing.large,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              radius: 30,
                              child: SmartImageView(SvgImageId.faceId.path),
                              onTap: () {
                                appLog('Face lock');
                                ref.safeExecute(
                                  key: "facelock",
                                  action: () => ref
                                      .read(biometricProvider.notifier)
                                      .authenticate(),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            Text(
                              "OR",
                              textAlign: TextAlign.center,
                              style: TextTheme.of(context).titleMedium,
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              radius: 30,
                              child: SmartImageView(SvgImageId.fingure.path),
                              onTap: () {
                                appLog('Fingure lock');
                              },
                            ),
                          ],
                        ),
                        VerticalSpacing.large,
                      ],
                    );
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don’t have an account? ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        appLog("Add function for rester now");
                        AppRouter.go(context, AppConstants.routeSignUp);
                      },
                      child: Text(
                        'Register Now',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  SignInViewModel createViewModel() {
    return ref.read(signInViewModelProvider);
  }

  @override
  String screenName() {
    return "Sign in screen";
  }

  _onSuccess(String message) {
    print('Google login result ');
    if (context.mounted) {
      AppRouter.go(context, AppConstants.routeLanding);
    }
  }

  _onFail(String message) {
    context.showError(message);
  }
}

class _MobileMailToggle extends StatelessWidget {
  final ValueNotifier toggleValue;
  const _MobileMailToggle({required this.toggleValue});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: toggleValue,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: !value ? Colors.black : Colors.white,
                  foregroundColor: value ? Colors.black : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                  ),
                ),
                onPressed: () => onPressed(false),
                child: Text('Email'),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: value ? Colors.black : Colors.white,
                  foregroundColor: !value ? Colors.black : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(0),
                      topLeft: Radius.circular(0),
                    ),
                  ),
                ),
                onPressed: () => onPressed(true),
                child: Text('Mobile'),
              ),
            ),
            Expanded(child: SizedBox()),
          ],
        );
      },
    );
  }

  void onPressed(bool value) {
    toggleValue.value = value;
  }
}

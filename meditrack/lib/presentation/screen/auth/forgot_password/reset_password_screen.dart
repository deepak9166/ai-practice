import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_input_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/spacing_widgets.dart';
import 'forgot_password_view_model.dart';

class ResetPasswordScreen extends StatelessWidget {
  final ForgotPasswordViewModel viewModel;
  const ResetPasswordScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          VerticalSpacing.small,
          RichTextTitle(
            title1: "Reset ",
            title2: "Password?",
            description:
                "Your new password must be different from previous used passwords.",
          ),

          VerticalSpacing.medium,
          CustomInputField(
            controller: viewModel.passwordController,
            label: 'New Password',
            hint: 'Enter New Password',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: Validators.validatePassword,
          ),

          VerticalSpacing.medium,
          CustomInputField(
            controller: viewModel.passwordController,
            label: 'Confirm Password',
            hint: 'Enter Confirm Password',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: Validators.validatePassword,
          ),
          VerticalSpacing.extraLarge,
          CustomButton(
            onPressed: () {
              AppRouter.push(context, AppConstants.routeForgotPasswordSuccess);
            },
            text: 'submit',
            isLoading: false,
          ),
        ],
      ),
    );
  }
}

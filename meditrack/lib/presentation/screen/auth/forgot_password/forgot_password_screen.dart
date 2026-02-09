import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';

import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_phone_number_field.dart';
import '../../../common_widgets/rich_text_title.dart';
import '../../../common_widgets/spacing_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          VerticalSpacing.small,
          RichTextTitle(
            title1: "Forgot ",
            title2: "Password?",
            description:
                "Please enter your registered mobile number we will send you the otp for verification",
          ),
          VerticalSpacing.medium,
          CustomInputPhoneNumberField(
            controller: TextEditingController(),
            label: 'Phone Number',
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            // validator: Validators.validatePhoneNumber,
          ),
          VerticalSpacing.extraLarge,
          CustomButton(
            onPressed: () {
              AppRouter.push(context, AppConstants.routeForgotPasswordVerify);
              
            },
            text: 'submit',
            isLoading: false,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

class WaitingApprovalWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback onButtonTap;

  const WaitingApprovalWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SmartImageView(icon),
        VerticalSpacing.extraLarge,
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.titleTextColor,
            fontSize: 28,
          ),
        ),
        VerticalSpacing.small,
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
        ),
        VerticalSpacing.extraLarge,
        CustomButton(
          onPressed: onButtonTap,
          width: MediaQuery.of(context).size.width * .75,
          text: buttonText ?? 'GO TO CUSTOM EXERCISES',
        ),
      ],
    );
  }
}

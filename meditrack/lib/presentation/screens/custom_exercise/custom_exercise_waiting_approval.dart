import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/waiting_approval_widget.dart';

class CustomExerciseWaitingApprovalScreen extends StatelessWidget {
  const CustomExerciseWaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: WaitingApprovalWidget(
            icon: SvgImageId.hourglass.path,
            title: "Waiting for admin’s approval",
            description:
                "You have successfully created the exercise. "
                "It is currently under review by admin. "
                "You will be notified once approved.",
            buttonText: "GO TO CUSTOM EXERCISES",
            onButtonTap: () {
              AppRouter.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

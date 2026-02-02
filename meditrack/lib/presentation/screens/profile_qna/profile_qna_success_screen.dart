import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../core/constants/app_constants.dart';

class ProfileQnaSuccessScreen extends StatelessWidget {
  const ProfileQnaSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: SmartImageView(SvgImageId.successCheckImage.path)),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.displaySmall,
            ),

            Text(
              'Thank you for sharing your preferences and targets.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            VerticalSpacing(size: 30),

            CustomButton(
              onPressed: () {
                AppRouter.go(context, AppConstants.routeProfileSetup);
              },
              text: "GO TO NEXT STEP",
            ),
          ],
        ),
      ),
    );
  }
}

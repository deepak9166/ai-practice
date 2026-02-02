import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_constants.dart';

import '../../../config/svg_config.dart';
import '../../../core/router/app_router.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/smart_image_view.dart';
import '../../common_widgets/spacing_widgets.dart';

class ProfileSetupSuccess extends StatelessWidget {
  const ProfileSetupSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SmartImageView(SvgImageId.preferenceSuccess.path),
            VerticalSpacing.large,

            Text(
              "Preferences Set\nSuccessfully!",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            VerticalSpacing.small,
            Text(
              "Congratulations, You have successfully \nset the preference",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            VerticalSpacing.large,
            CustomButton(
              onPressed: () {
                AppRouter.go(context, AppConstants.routeSignIn);
              },
              text: 'GO TO HOME PAGE',
            ),
            VerticalSpacing.large,
          ],
        ),
      ),
    );
  }
}

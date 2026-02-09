import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/spacing_widgets.dart';

class SignUpSuccess extends StatelessWidget {
  const SignUpSuccess({super.key});

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
              "Successfully",
              style: Theme.of(context).textTheme.displaySmall
            ),
            VerticalSpacing.small,
            Text(
              "You have successfully verified\nthe account.",
              textAlign: TextAlign.center,
              style:  Theme.of(context).textTheme.bodyLarge,
            ),
            VerticalSpacing.large,
            CustomButton(
              onPressed: () {
                AppRouter.go(context, AppConstants.routeProfileQnA);
              },
              text: 'Done',
            ),
            VerticalSpacing.large,
          ],
        ),
      ),
    );
  }
}

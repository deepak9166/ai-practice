import 'package:flutter/material.dart';

import '../../../../config/png_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../log/app_logs.dart';
import '../../add_workout/common_widgets/workout_group_card.dart';

class WorkoutTemplatesList extends StatelessWidget {
  const WorkoutTemplatesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 108,
            child: WorkoutGroupCard(
              title: "Arm Circles",
              imagePath: PngImageId.yoga.path,
              isSelected: false,
              onTap: () {
                AppRouter.push(context, AppConstants.routeTemplateDetail);
              },
              onThreeDotsTap: () {
                appLog('three dot tapped');
                
              },
              showDottedBorder: false,
              showThreeDots: false,
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 15),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../log/app_logs.dart';
import '../../../common_model/exercise_model.dart';
import '../../../common_widgets/exercise_card.dart';

class UpcomingExerciseList extends StatelessWidget {
  const UpcomingExerciseList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 170,
            child: ExerciseCard(
              cardType: ExeciseCardType.small,
              item: ExerciseModel(
                date: DateTime.now().toIso8601String(),
                msgNames: 'Chest, Arms , Arm sdffd f f f',
                name: 'Upper Body Strength',
                previewImages: [PngImageId.yoga.path,PngImageId.yoga.path,PngImageId.yoga.path,],
                status: '',
              ),
              onAction: () {
                appLog('Add navigation for Open full detail'); // TODO:
                AppRouter.push(context, AppConstants.routeTodayWorkout); // TODO: manage title for upcoming
              },
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemCount: 8,
      ),
    );
  }
}

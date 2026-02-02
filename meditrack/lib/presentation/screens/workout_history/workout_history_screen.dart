import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_model/exercise_model.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/exercise_card.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/enum/workout_category_enum.dart';
import 'package:meditrack/presentation/screens/workout_history/view_model/workout_history_view_model.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryState();
}

class _WorkoutHistoryState
    extends BaseConsumerState<WorkoutHistoryScreen, WorkoutHistoryViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(hideLeading: true, title: 'Workout History'),
      body: SafeArea(
        child: _buildExerciseTable(WorkoutCategory.admin, viewModel.exercises),
      ),
    );
  }

  Widget _buildExerciseTable(
    WorkoutCategory category,
    ValueNotifier<List<String>> exercisesNotifier,
  ) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: exercisesNotifier,
      builder: (context, exercises, child) {
        return ListView.separated(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (context, index) {
            return VerticalSpacing();
          },
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseCard(
              item: ExerciseModel(
                date: DateTime.now().toIso8601String(),
                msgNames: 'Chest, Arms, Shoulders',
                name: exercise,
                previewImages: [
                  PngImageId.yoga.path,
                  PngImageId.yoga.path,
                  PngImageId.yoga.path,
                ],
                status: '',
              ),
              cardType: ExeciseCardType.normal,
              buttonIcon: SvgImageId.edit.path,
              onTopBtnTapped: (offset) {
                appLog('edit actions recieved');
                AppRouter.push(context, AppConstants.routeWorkoutDetailEdit);
              },
              onAction: () {
                appLog('Add navigation for Open full detail');
                AppRouter.push(context, AppConstants.routeWorkoutHistoryDetail);
              },
            );
          },
        );
      },
      // },
    );
  }

  @override
  WorkoutHistoryViewModel createViewModel() {
    return ref.read(workoutHistoryViewModelProvider);
  }

  @override
  String screenName() {
    return "Workout History Screen";
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_model/exercise_model.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_template_popup_menu.dart';
import 'package:meditrack/presentation/common_widgets/exercise_card.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/work_scheduling/view_model/scheduling_view_model.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/enum/workout_category_enum.dart';

class FutureWorkScheduling extends ConsumerStatefulWidget {
  const FutureWorkScheduling({super.key});

  @override
  ConsumerState<FutureWorkScheduling> createState() =>
      _FutureWorkSchedulingState();
}

class _FutureWorkSchedulingState
    extends BaseConsumerState<FutureWorkScheduling, SchedulingViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hideLeading: true,
        title: 'Future Work Scheduling',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AppRouter.push(context, AppConstants.routeAddWorkout);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 4.0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Admin'),
                  Tab(text: 'Custom'),
                  Tab(text: 'Shared'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildExerciseTable(
                      WorkoutCategory.admin,
                      viewModel.adminExercises,
                    ),
                    _buildExerciseTable(
                      WorkoutCategory.custom,
                      viewModel.customExercises,
                    ),
                    _buildExerciseTable(
                      WorkoutCategory.shared,
                      viewModel.sharedExercises,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                previewImages: [],
                status: '',
              ),
              cardType: ExeciseCardType.medium,
              buttonIcon: SvgImageId.moreDots.path,
              onTopBtnTapped: (offset) {
                appLog('more actions recieved');
                CustomTemplatePopupMenu.show(
                  context,
                  options: const [
                    {'value': 'edit_workout', 'text': 'Edit Workout'},
                    {'value': 'delete_workout', 'text': 'Delete Workout'},
                  ],
                  onSelected: (value) {
                    // Handle menu item selection
                    switch (value) {
                      case 'edit_workout':
                        appLog('Edit Workout');
                        break;
                      case 'delete_workout':
                        appLog('Delete Workout');
                        break;
                    }
                  },
                  position: offset,
                );
              },
              onAction: () {
                appLog('Add navigation for Open full detail');
              },
            );
          },
        );
      },
      // },
    );
  }

  @override
  SchedulingViewModel createViewModel() {
    return ref.read(schedulingViewModelProvider);
  }

  @override
  String screenName() {
    return "Future Work Scheduling Screen";
  }
}

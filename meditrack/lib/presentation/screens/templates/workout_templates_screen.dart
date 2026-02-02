import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';
import 'package:meditrack/presentation/common_widgets/custom_search_bar.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/exercise_filter.dart';
import 'package:meditrack/enum/filter_enum.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/workout_group_card.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/enum/workout_category_enum.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';

import '../../common_widgets/spacing_widgets.dart';

/// Workout Templates Screen
///
/// Screen for displaying and managing workout templates.
class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState
    extends BaseConsumerState<WorkoutTemplatesScreen, TemplatesViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(hideLeading: true, title: 'Workout Templates'),
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
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   VerticalSpacing.mediumExtra,
                  // Search
                  CustomSearchBarView(
                    hintText: 'Search Templates',
                    onPressed: () {
                      context.hideKeyboard();
                    },
                  ),
                  VerticalSpacing.mediumExtra,
                  // Excercise
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ExerciseFilter(
                      onSelectFilter: (type) {
                        appLog('Select value : -- $type');
                      },
                      allowFilter: [
                        FilterTypes.mmg,
                        FilterTypes.msg,
                        FilterTypes.equipments,
                        FilterTypes.templateType,
                        FilterTypes.customExcercise,
                      ],
                    ),
                  ),
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
    ValueNotifier<List<Exercise>> exercisesNotifier,
  ) {
    return ValueListenableBuilder<List<Exercise>>(
      valueListenable: exercisesNotifier,
      builder: (context, exercises, child) {
        // if (exercises.isEmpty) {
        //   return const Center(child: Text('No templates available'));
        // } else {
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 137,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return WorkoutGroupCard(
              title: exercise.name,
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
            );
          },
        );
      },
      // },
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Workout Templates Screen";
  }
}

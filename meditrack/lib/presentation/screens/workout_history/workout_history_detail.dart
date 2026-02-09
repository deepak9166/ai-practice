import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/presentation/common_model/exercise_model.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/exercise_card.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/slider_container.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/enum/workout_category_enum.dart';
import 'package:meditrack/presentation/screens/workout_history/common_widget/workout_img_widget.dart';
import 'package:meditrack/presentation/screens/workout_history/view_model/workout_history_view_model.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/exercise_detail_item.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class WorkoutHistoryDetail extends ConsumerStatefulWidget {
  const WorkoutHistoryDetail({super.key});

  @override
  ConsumerState<WorkoutHistoryDetail> createState() =>
      _WorkoutHistoryDetailState();
}

class _WorkoutHistoryDetailState
    extends BaseConsumerState<WorkoutHistoryDetail, TemplatesViewModel>
    with ImagePickerUtils {
  var image = PngImageId.chest.path;
  @override
  Widget build(BuildContext context) {
    final workoutHistoryViewModel = ref.read(workoutHistoryViewModelProvider);
    return Scaffold(
      appBar: CustomAppBar(
        hideLeading: true,
        title: 'Detail',
        actions: [
        
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ExerciseCard(
                  item: ExerciseModel(
                    date: DateTime.now().toIso8601String(),
                    msgNames: 'Chest, Arms, Shoulders',
                    name: 'Upper Body Strength',
                    previewImages: [],
                    status: '',
                  ),
                  cardType: ExeciseCardType.normal,
                  // onAction: () {
                  //   appLog('Add navigation for Open full detail');
                  //   AppRouter.push(
                  //     context,
                  //     AppConstants.routeWorkoutHistoryDetail,
                  //   );
                  // },
                ),
              ),
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
                      workoutHistoryViewModel,
                    ),
                    _buildExerciseTable(
                      WorkoutCategory.custom,
                      viewModel.customExercises,
                      workoutHistoryViewModel,
                    ),
                    _buildExerciseTable(
                      WorkoutCategory.shared,
                      viewModel.sharedExercises,
                      workoutHistoryViewModel,
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
    WorkoutHistoryViewModel workoutHistoryViewModel,
  ) {
    return ValueListenableBuilder<List<Exercise>>(
      valueListenable: viewModel.listExercises,
      builder: (context, exercises, child) {
        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            ...exercises.asMap().entries.map(
              (entry) => ExerciseDetailItem(
                exercise: entry.value,
                index: entry.key,
                viewModel: viewModel,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Workout Entry at MMG-2.0 ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppTheme.titleTextColor,
                        ),
                      ),
                      TextSpan(
                        text: '(Optional)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppTheme.titleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: workoutHistoryViewModel.workoutEntryToggle,
                  builder: (context, value, child) {
                    return Switch(
                      value: value,
                      onChanged: (newValue) {
                        workoutHistoryViewModel.workoutEntryToggle.value =
                            newValue;
                      },
                    );
                  },
                ),
              ],
            ),
            VerticalSpacing.medium,
            ValueListenableBuilder<bool>(
              valueListenable: workoutHistoryViewModel.workoutEntryToggle,
              builder: (context, isToggled, child) {
                if (!isToggled) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...workoutHistoryViewModel.workoutEntries.map((entry) {
                      return Column(
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: entry.value,
                            builder: (context, value, child) {
                              return SliderContainer(
                                title: entry.title,
                                value: value,
                                onChanged: (newValue) {
                                  entry.value.value = newValue;
                                },
                              );
                            },
                          ),
                          VerticalSpacing.medium,
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
            VerticalSpacing.small,
            WorkoutImgWidget(
              imagePath: PngImageId.chest.path,
              title: 'Image.jpeg',
              subtitle: 'Image.jpeg',
            ),
          ],
        );
      },
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Workout History Detail Screen";
  }
}

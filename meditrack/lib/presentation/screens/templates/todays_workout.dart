import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/extension/sage_execute_extesion.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_item.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/slider_container.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import 'package:image_picker/image_picker.dart';
import '../add_workout/view_model/add_workout_viewmodel.dart';
import '../add_workout/common_widgets/no_exercises_widget.dart';

/// Today's Workout Screen
///
/// Screen for today's workout with exercises.
class TodaysWorkoutScreen extends ConsumerStatefulWidget {
  const TodaysWorkoutScreen({super.key});

  @override
  ConsumerState<TodaysWorkoutScreen> createState() =>
      _TodaysWorkoutScreenState();
}

class _TodaysWorkoutScreenState
    extends BaseConsumerState<TodaysWorkoutScreen, AddWorkoutViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<XFile?> _selectedImage = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: CustomAppBar(
        title: 'Today\'s Workout',
        actions: [

           SizedBox(
            height: 23,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Finish',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),

        
          HorizontalSpacing.medium,
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomInputField(
                          controller: viewModel.workoutNameController,
                          hint: 'Enter workout name (optional)',
                        ),
                        VerticalSpacing.medium,
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    viewModel.dateController.text =
                                        '${picked.day}-${picked.month}-${picked.year}';
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD0C9EA,
                                    ).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          viewModel
                                                  .dateController
                                                  .text
                                                  .isNotEmpty
                                              ? viewModel.dateController.text
                                              : 'Date',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        SvgImageId.calendar.path,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                  if (picked != null) {
                                    viewModel.startTimeController.text = picked
                                        .format(context);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD0C9EA,
                                    ).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          viewModel
                                                  .startTimeController
                                                  .text
                                                  .isNotEmpty
                                              ? viewModel
                                                    .startTimeController
                                                    .text
                                              : 'Start Time',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        SvgImageId.clock.path,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing.medium,
                        Row(
                          children: [
                            Expanded(
                              child: CustomInputField(
                                controller: viewModel.durationController,
                                hint: 'Duration (optional)',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomInputField(
                                controller: viewModel.caloriesController,
                                hint: 'Calories (optional)',
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing.large,
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                indicatorColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                indicatorWeight: 4.0,
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: const [
                                  Tab(text: 'Strength'),
                                  Tab(text: 'Cardio'),
                                  Tab(text: 'Other'),
                                ],
                              ),
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  children: [
                                    _buildExerciseTable(
                                      'strength',
                                      viewModel.strengthExercises,
                                    ),
                                    _buildExerciseTable(
                                      'cardio',
                                      viewModel.cardioExercises,
                                    ),
                                    _buildExerciseTable(
                                      'other',
                                      viewModel.otherExercises,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalSpacing.medium,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Workout Entry at MMG-2.0 ',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: AppTheme.titleTextColor,
                                        ),
                                  ),
                                  TextSpan(
                                    text: '(Optional)',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: AppTheme.titleTextColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: viewModel.workoutEntryToggle,
                              builder: (context, value, child) {
                                return Switch(
                                  value: value,
                                  onChanged: (newValue) {
                                    viewModel.workoutEntryToggle.value =
                                        newValue;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        VerticalSpacing.medium,
                        ValueListenableBuilder<bool>(
                          valueListenable: viewModel.workoutEntryToggle,
                          builder: (context, isToggled, child) {
                            if (!isToggled) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...viewModel.workoutEntries.map((entry) {
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
                        Text(
                          'Capture Visual Progress',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: AppTheme.titleTextColor,
                              ),
                        ),
                        VerticalSpacing.small,
                        Text(
                          'Capture Visual Progress',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppTheme.titleTextColor,
                              ),
                        ),
                        VerticalSpacing.small,
                        ValueListenableBuilder<XFile?>(
                          valueListenable: _selectedImage,
                          builder: (context, image, child) {
                            return GestureDetector(
                              onTap: _pickImage,
                              child: DottedBorder(
                                color: Colors.grey,
                                strokeWidth: 0.5,
                                dashPattern: [6, 3],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(8),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(image.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 24,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Upload image (Optional)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        VerticalSpacing.large,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScreenStateAware(
                  showApiProgressInPlace: true,
                  state: viewModel.screenState,
                  builder: (context) => CustomButton(
                    onPressed: () {
                      ref.safeExecute(
                        key: "save_workout",
                        action: () => viewModel.saveWorkout(context),
                      );
                    },
                    text: 'ADD EXERCISE',
                    backgroundColor: Colors.black,
                    isLoading:
                        viewModel.screenState.value == ScreenState.apiProgress,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTable(
    String category,
    ValueNotifier<List<ExerciseViewModel>> exercisesNotifier,
  ) {
    return ValueListenableBuilder<List<ExerciseViewModel>>(
      valueListenable: exercisesNotifier,
      builder: (context, exercises, child) {
        if (exercises.isEmpty) {
          return NoExercisesWidget(onAdd: () => _addExercise(category));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              VerticalSpacing.medium,
              ...exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exerciseVM = entry.value;
                return ExerciseItem(
                  viewModel: exerciseVM,
                  onRemove: () => viewModel.removeExercise(category, index),
                );
              }),
              VerticalSpacing.medium,
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await pickImage(context);
    if (image != null) {
      _selectedImage.value = image;
    }
  }

  void _addExercise(String category) {
    // For simplicity, add a default exercise with 3 sets
    final sets = List.generate(1, (_) => ExerciseSet(reps: 10));
    final exercise = Exercise(name: 'New Exercise', sets: sets);
    viewModel.addExercise(category, exercise);
  }

  @override
  void dispose() {
    _selectedImage.dispose();
    super.dispose();
  }

  @override
  AddWorkoutViewModel createViewModel() {
    return ref.read(addWorkoutViewModelProvider);
  }

  @override
  String screenName() {
    return "Today's Workout Screen";
  }
}

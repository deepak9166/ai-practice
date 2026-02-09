
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/extension/sage_execute_extesion.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_model/action_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/user_image_upload_bottom_sheet.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_item.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/slider_container.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import '../../common_widgets/visual_profress_viewer.dart';
import 'view_model/add_workout_viewmodel.dart';
import 'common_widgets/no_exercises_widget.dart';

/// Add Workout Screen
///
/// Screen for creating a new workout with exercises.
class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState
    extends BaseConsumerState<AddWorkoutScreen, AddWorkoutViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _selectedImage = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Workout'),
        actions: [
          ActionButtonAppBar(
            title: 'Finish',
            onPressed: () {
              appLog('finish tapped');
            },
          ),
          SizedBox(width: 20),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
                              color: const Color(0xFFD0C9EA).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    viewModel.dateController.text.isNotEmpty
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
                            final TimeOfDay? picked = await showTimePicker(
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
                              color: const Color(0xFFD0C9EA).withOpacity(0.4),
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
                                        ? viewModel.startTimeController.text
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
                          indicatorColor: Theme.of(context).colorScheme.primary,
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
                              viewModel.workoutEntryToggle.value = newValue;
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
                  VerticalSpacing.small,
                  VisualProgressViewer(
                    height: 80,
                    title: 'Capture Visual Progress',
                    subtitle: 'Capture Visual Progress',
                    placeHolder: 'Upload image(JPG/PNG)',
                    imageNotifier: _selectedImage,
                    onPickImage: () => _pickImage(),
                    onRemove: () {
                      appLog('removed images');
                      _selectedImage.value = "";
                    },
                  ),
                  VerticalSpacing.large,
                  ScreenStateAware(
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
                          viewModel.screenState.value ==
                          ScreenState.apiProgress,
                    ),
                  ),
                ],
              ),
            ),
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
    // final XFile? image = await pickImage(context);
    // if (image != null) {
    // _selectedImage.value = image;
    // }

    showModalBottomSheet(
      context: context,
      builder: (context) => UserImageUploadBottomSheet(
        onUpload: (imageUrl, msgLevel) {
          appLog('Image URL: $imageUrl, MSG Level: $msgLevel');
          _selectedImage.value = imageUrl;
        },
      ),
    );
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
    return "Add Workout Screen";
  }
}

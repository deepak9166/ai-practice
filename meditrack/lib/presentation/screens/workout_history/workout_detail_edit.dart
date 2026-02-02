import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/slider_container.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import 'package:meditrack/presentation/screens/workout_history/common_widget/workout_img_widget.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/template_exercise_item.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class WorkoutDetailEdit extends ConsumerStatefulWidget {
  const WorkoutDetailEdit({super.key});

  @override
  ConsumerState<WorkoutDetailEdit> createState() => _WorkoutDetailEditState();
}

class _WorkoutDetailEditState
    extends BaseConsumerState<WorkoutDetailEdit, TemplatesViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<XFile?> _selectedImage = ValueNotifier(null);
  void _removeExercise(int index) {
    final exercises = List<Exercise>.from(viewModel.listExercises.value);
    exercises.removeAt(index);
    viewModel.listExercises.value = exercises;
  }

  Future<void> _pickImage() async {
    final XFile? image = await pickImage(context);
    if (image != null) {
      _selectedImage.value = image;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutHistoryViewModel = ref.read(workoutHistoryViewModelProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Detail',
        defaultActionTitle: 'SAVE',
        onDefaultActionPressed: () {
          appLog('on WorkoutDetailEdit Save tapped');
        },
      ),
      body: SafeArea(
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
                        controller:
                            workoutHistoryViewModel.workoutNameController,
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
                                  workoutHistoryViewModel.dateController.text =
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
                                        workoutHistoryViewModel
                                                .dateController
                                                .text
                                                .isNotEmpty
                                            ? workoutHistoryViewModel
                                                  .dateController
                                                  .text
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
                                  workoutHistoryViewModel
                                      .startTimeController
                                      .text = picked.format(
                                    context,
                                  );
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
                                        workoutHistoryViewModel
                                                .startTimeController
                                                .text
                                                .isNotEmpty
                                            ? workoutHistoryViewModel
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
                              controller:
                                  workoutHistoryViewModel.durationController,
                              hint: 'Duration',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              controller:
                                  workoutHistoryViewModel.caloriesController,
                              hint: 'Calories (optional)',
                            ),
                          ),
                        ],
                      ),
                      VerticalSpacing.medium,
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<List<Exercise>>(
                        valueListenable: viewModel.listExercises,
                        builder: (context, exercises, child) {
                          return Column(
                            children: exercises.asMap().entries.map((entry) {
                              final index = entry.key;
                              final exercise = entry.value;
                              final exerciseViewModel =
                                  TemplateExerciseViewModel(exercise);
                              return TemplateExerciseItem(
                                viewModel: exerciseViewModel,
                                rightBtnTitle: '+ Set',
                                onRemove: () => _removeExercise(index),
                              );
                            }).toList(),
                          );
                        },
                      ),
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
                            valueListenable:
                                workoutHistoryViewModel.workoutEntryToggle,
                            builder: (context, value, child) {
                              return Switch(
                                value: value,
                                onChanged: (newValue) {
                                  workoutHistoryViewModel
                                          .workoutEntryToggle
                                          .value =
                                      newValue;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<bool>(
                        valueListenable:
                            workoutHistoryViewModel.workoutEntryToggle,
                        builder: (context, isToggled, child) {
                          if (!isToggled) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...workoutHistoryViewModel.workoutEntries.map((
                                entry,
                              ) {
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
                      ValueListenableBuilder<XFile?>(
                        valueListenable: _selectedImage,
                        builder: (context, image, child) {
                          return WorkoutImgWidget(
                            imagePath: PngImageId.chest.path,
                            title: 'Image.jpeg',
                            subtitle: 'Image.jpeg',
                            onCancel: () {
                              appLog('cancel image tapped');
                            },
                            onEdit: () {
                              _pickImage();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalSpacing.medium,
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ScreenStateAware(
                showApiProgressInPlace: true,
                state: viewModel.screenState,
                builder: (context) => CustomButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    context.pop();
                  },
                  text: 'ADD EXERCISE',
                  isLoading:
                      viewModel.screenState.value == ScreenState.apiProgress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Workout Detail Screen";
  }
}

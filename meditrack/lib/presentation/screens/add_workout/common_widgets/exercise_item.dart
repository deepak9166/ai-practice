import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_popup_dialog.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_input_field.dart';
import '../view_model/add_workout_viewmodel.dart';

class ExerciseItem extends StatelessWidget {
  final ExerciseViewModel viewModel;
  final VoidCallback onRemove;

  const ExerciseItem({
    super.key,
    required this.viewModel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: const Color.fromRGBO(243, 243, 243, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Exercise Header
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(208, 201, 234, 0.4),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/img/chest.png'),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.nameController.text,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.titleTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => viewModel.toggleItemExpansion(),
                      icon: Icon(
                        viewModel.itemExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await CustomPopupDialog.show(
                          context: context,
                          content:
                              "Are you sure you want to remove this exercise?",
                          actions: [
                            DialogAction(text: "Cancel", isPrimary: false),
                            DialogAction(
                              text: "Yes, Remove",
                              isPrimary: true,
                              onPressed: onRemove,
                            ),
                          ],
                        );
                      },
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (viewModel.itemExpanded) ...[
                // Individual Set Cards
                ...List.generate(
                  viewModel.getControllers(ExerciseField.reps).length,
                  (i) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Set Header
                            Row(
                              children: [
                                Text(
                                  'Set ${i + 1}',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.titleTextColor,
                                      ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () async {
                                    await CustomPopupDialog.show(
                                      context: context,
                                      content:
                                          "Are you sure you want to remove this set?",
                                      actions: [
                                        DialogAction(
                                          text: "Cancel",
                                          isPrimary: false,
                                        ),
                                        DialogAction(
                                          text: "Yes, Remove",
                                          isPrimary: true,
                                          onPressed: () =>
                                              viewModel.removeSet(i),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      viewModel.toggleSetExpansion(i),
                                  icon: Icon(
                                    viewModel.setExpandedStates[i]
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                ),
                              ],
                            ),
                            // Collapsed Set Summary
                            if (!viewModel.setExpandedStates[i]) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Builder(
                                  builder: (context) {
                                    final reps =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.reps,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.reps,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.reps,
                                              )[i]
                                              .text
                                        : null;
                                    final weight =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.weight,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.weight,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.weight,
                                              )[i]
                                              .text
                                        : null;
                                    final assistedWeight =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.assistedWeight,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.assistedWeight,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.assistedWeight,
                                              )[i]
                                              .text
                                        : null;
                                    final extraWeight =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.extraWeight,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.extraWeight,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.extraWeight,
                                              )[i]
                                              .text
                                        : null;
                                    final bodyWeight =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.bodyWeight,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.bodyWeight,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.bodyWeight,
                                              )[i]
                                              .text
                                        : null;
                                    final duration =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.duration,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.duration,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.duration,
                                              )[i]
                                              .text
                                        : null;
                                    final distance =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.distance,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.distance,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.distance,
                                              )[i]
                                              .text
                                        : null;
                                    final calorieBurned =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.calorieBurned,
                                            ) &&
                                            viewModel
                                                .getControllers(
                                                  ExerciseField.calorieBurned,
                                                )[i]
                                                .text
                                                .isNotEmpty
                                        ? viewModel
                                              .getControllers(
                                                ExerciseField.calorieBurned,
                                              )[i]
                                              .text
                                        : null;

                                    /// collapse view summary
                                    String summary = '';
                                    if (weight != null && reps != null) {
                                      summary = '$weight kg x $reps Reps';
                                    } else if (weight != null) {
                                      summary = '$weight kg';
                                    } else if (reps != null) {
                                      summary = '$reps Reps';
                                    } else if (assistedWeight != null) {
                                      summary = '$assistedWeight kg (Assisted)';
                                    } else if (extraWeight != null) {
                                      summary = '$extraWeight kg (Extra)';
                                    } else if (bodyWeight != null) {
                                      summary = '$bodyWeight kg (Body)';
                                    } else if (duration != null) {
                                      summary = '$duration mins';
                                    } else if (distance != null) {
                                      summary = '$distance Mile';
                                    } else if (calorieBurned != null) {
                                      summary = '$calorieBurned cal';
                                    }

                                    return Text(
                                      summary,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            // Set Content
                            if (viewModel.setExpandedStates[i]) ...[
                              if (viewModel.enabledFields.contains(
                                ExerciseField.reps,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Reps ',
                                  secondaryLabel: '',
                                  controller: viewModel.getControllers(
                                    ExerciseField.reps,
                                  )[i],
                                  isPickerEnabled: true,
                                  pickerType: 'reps',
                                  onIncrement: () => viewModel.incrementReps(i),
                                  onDecrement: () => viewModel.decrementReps(i),
                                ),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.weight,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Weight ',
                                  secondaryLabel: '(kg)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.weight,
                                  )[i],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.assistedWeight,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Assisted Weight ',
                                  secondaryLabel: '(kg)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.assistedWeight,
                                  )[i],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.extraWeight,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Extra Weight ',
                                  secondaryLabel: '(kg)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.extraWeight,
                                  )[i],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.bodyWeight,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Body Weight ',
                                  secondaryLabel: '(kg)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.bodyWeight,
                                  )[i],
                                  isPickerEnabled: true,
                                  pickerType: 'weight',
                                  onPickerValueSelected: (value) {
                                    // Optional callback if needed
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.duration,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Duration ',
                                  secondaryLabel: '(mins)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.duration,
                                  )[i],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.distance,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Distance ',
                                  secondaryLabel: '(Mile)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.distance,
                                  )[i],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (viewModel.enabledFields.contains(
                                ExerciseField.calorieBurned,
                              )) ...[
                                ExerciseInputField(
                                  label: 'Calorie Burned ',
                                  secondaryLabel: '(cal)',
                                  controller: viewModel.getControllers(
                                    ExerciseField.calorieBurned,
                                  )[i],
                                ),
                              ],
                            ],
                            VerticalSpacing.medium,
                            Divider(height: 0.5, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Set Button
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 57,
                        height: 28,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'RedHatDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      HorizontalSpacing.medium,
                      SizedBox(
                        width: 75,
                        height: 28,
                        child: OutlinedButton(
                          onPressed: viewModel.addSet,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Add Set',
                            style: TextStyle(
                              fontFamily: 'RedHatDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

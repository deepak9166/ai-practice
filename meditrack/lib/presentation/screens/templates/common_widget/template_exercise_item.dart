import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_popup_dialog.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_input_field.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class TemplateExerciseItem extends StatelessWidget {
  final TemplateExerciseViewModel viewModel;
  final String? leftBtnTitle;
  final String? rightBtnTitle;
  final VoidCallback onRemove;

  const TemplateExerciseItem({
    super.key,
    required this.viewModel,
    this.leftBtnTitle,
    this.rightBtnTitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Card(
          color: const Color.fromRGBO(243, 243, 243, 1),
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Exercise Header
              Container(
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
                                    final duration =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.duration,
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
                                    final distance =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.distance,
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
                                    final calorieBurned =
                                        viewModel.enabledFields.contains(
                                              ExerciseField.calorieBurned,
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

                                    /// collapse view summary
                                    String summary = '';
                                    if (weight != null && reps != null) {
                                      summary = '$weight lbs x $reps Reps';
                                    } else if (weight != null) {
                                      summary = '$weight lbs';
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
                              ...viewModel.enabledFields.map((field) {
                                final config = viewModel.getConfig(field);
                                return Column(
                                  children: [
                                    ExerciseInputField(
                                      label: config.label,
                                      secondaryLabel: config.secondaryLabel,
                                      controller: viewModel.getControllers(
                                        field,
                                      )[i],
                                      isPickerEnabled: config.isPickerEnabled,
                                      pickerType: config.pickerType,
                                      onIncrement: config.hasIncrementDecrement
                                          ? () => viewModel.incrementValue(
                                              field,
                                              i,
                                            )
                                          : null,
                                      onDecrement: config.hasIncrementDecrement
                                          ? () => viewModel.decrementValue(
                                              field,
                                              i,
                                            )
                                          : null,
                                      onPickerValueSelected:
                                          config.isPickerEnabled
                                          ? (value) {
                                              // Optional callback if needed
                                            }
                                          : null,
                                    ),
                                    if (field != viewModel.enabledFields.last)
                                      const SizedBox(height: 8),
                                  ],
                                );
                              }),
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
                      if (leftBtnTitle?.isEmpty ?? true)
                        Expanded(
                          child: Text(
                            'Add Set',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.titleTextColor,
                                ),
                          ),
                        ),
                      if (leftBtnTitle?.isNotEmpty ?? false)
                        SizedBox(
                          width: 85,
                          height: 28,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              leftBtnTitle ?? 'Save',
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: AppTheme.primaryThemeColor,
                                  ),
                            ),
                          ),
                        ),
                      if (rightBtnTitle?.isNotEmpty ?? false)
                        HorizontalSpacing.medium,
                      if (rightBtnTitle?.isNotEmpty ?? false)
                        SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            onPressed: viewModel.addSet,
                            style: OutlinedButton.styleFrom(
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
                            child: Text(
                              rightBtnTitle ?? 'Add Set',
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class ExerciseDetailItem extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final TemplatesViewModel viewModel;

  const ExerciseDetailItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel.exerciseExpandedStates,
        viewModel.setExpandedStates,
      ]),
      builder: (context, child) {
        final itemExpanded = viewModel.exerciseExpandedStates.value[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: AppTheme.dividerColor,
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
                    SmartImageView(
                      exercise.exerciseImg ?? 'assets/img/chest.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.titleTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => viewModel.toggleExerciseExpansion(index),
                      icon: Icon(
                        itemExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                  ],
                ),
              ),
              if (itemExpanded) ...[
                // Individual Set Cards
                ...List.generate(exercise.sets.length, (i) {
                  final setExpanded =
                      viewModel.setExpandedStates.value[index][i];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Set Header
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Set ${i + 1}',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  viewModel.toggleSetExpansion(index, i),
                              icon: Icon(
                                setExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ),
                          ],
                        ),
                        if (setExpanded) ...[
                          const SizedBox(height: 8),
                          // Set Content
                          if (exercise.enabledFields.contains(
                            ExerciseField.reps,
                          )) ...[
                            Row(
                              children: [
                                SizedBox(
                                  width: 114,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Reps ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                        TextSpan(
                                          text: '(lbs)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    exercise.sets[i].reps.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.titleTextColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (exercise.enabledFields.contains(
                            ExerciseField.weight,
                          )) ...[
                            Row(
                              children: [
                                SizedBox(
                                  width: 114,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Weight ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                        TextSpan(
                                          text: '(kg)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 114,
                                  child: Text(
                                    exercise.sets[i].weight.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.titleTextColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (exercise.enabledFields.contains(
                            ExerciseField.duration,
                          )) ...[
                            Row(
                              children: [
                                SizedBox(
                                  width: 114,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Duration ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                        TextSpan(
                                          text: '(mins)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: AppTheme
                                                    .descriptionTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    exercise.sets[i].duration.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.titleTextColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          VerticalSpacing.medium,
                        ] else ...[
                          Text(
                            _buildSummary(
                              exercise.sets[i],
                              exercise.enabledFields,
                            ),
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                        const VerticalSpacing(),
                        if (i < exercise.sets.length - 1)
                          Divider(height: 0.5, color: Colors.grey.shade300),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _buildSummary(ExerciseSet set, Set<ExerciseField> enabledFields) {
  String summary = '';
  final weight = set.weight;
  final reps = set.reps;
  final assistedWeight = set.assistedWeight;
  final extraWeight = set.extraWeight;
  final bodyWeight = set.bodyWeight;
  final duration = set.duration;
  final distance = set.distance;
  final calorieBurned = set.calorieBurned;

  if (enabledFields.contains(ExerciseField.weight) &&
      weight > 0 &&
      enabledFields.contains(ExerciseField.reps) &&
      reps > 0) {
    summary = '$weight kg x $reps Reps';
  } else if (enabledFields.contains(ExerciseField.weight) && weight > 0) {
    summary = '$weight kg';
  } else if (enabledFields.contains(ExerciseField.reps) && reps > 0) {
    summary = '$reps Reps';
  } else if (enabledFields.contains(ExerciseField.assistedWeight) &&
      assistedWeight > 0) {
    summary = '$assistedWeight kg (Assisted)';
  } else if (enabledFields.contains(ExerciseField.extraWeight) &&
      extraWeight > 0) {
    summary = '$extraWeight kg (Extra)';
  } else if (enabledFields.contains(ExerciseField.bodyWeight) &&
      bodyWeight > 0) {
    summary = '$bodyWeight kg (Body)';
  } else if (enabledFields.contains(ExerciseField.duration) && duration > 0) {
    summary = '$duration mins';
  } else if (enabledFields.contains(ExerciseField.distance) && distance > 0) {
    summary = '$distance Mile';
  } else if (enabledFields.contains(ExerciseField.calorieBurned) &&
      calorieBurned > 0) {
    summary = '$calorieBurned cal';
  }

  return summary;
}

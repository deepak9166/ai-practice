
import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/status_label_widget.dart';

import 'info_tag.dart';

class ExerciseOverview extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseOverview({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InfoWidget.tag(
              iconPath: SvgImageId.strength.path,
              text: 'MMG 2.0',
              titleTextColor: Colors.white,
              backgroundColor: AppTheme.titleTextColor,
            ),
            const Spacer(),
            StatusLabelWidget(status: exercise['status'] ?? ''),
          ],
        ),

        VerticalSpacing(),

        /// TITLE
        Text(
          exercise['title'] ?? '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 26,
            color: AppTheme.titleTextColor,
          ),
        ),

        VerticalSpacing(),

        /// TAGS
        Row(
          children: [
            InfoWidget.tag(
              iconPath: SvgImageId.strength.path,
              text: 'Chest, Arms, Shoulders, Legs',
            ),
            HorizontalSpacing(),
            InfoWidget.tag(
              iconPath: SvgImageId.templatesType.path,
              text: 'Trade-mill',
            ),
          ],
        ),

        VerticalSpacing(),

        /// MUSCLE GROUP
        InfoWidget.muscleGroup(
          title: 'MMG',
          titleValue: 'Chest, Shoulders, Traps, Lats',
        ),

        VerticalSpacing(),

        /// MUSCLE DISTRIBUTION
        InfoWidget.muscleGroup(
          title: 'MMG',
          titleValueList: const [
            {'key': 'Upper Chest', 'value': '0.75'},
            {'key': 'Middle Chest', 'value': '0.75'},
            {'key': 'Lower Chest', 'value': '0.75'},
          ],
        ),

        VerticalSpacing(),

        /// DESCRIPTION
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppTheme.titleTextColor,
          ),
        ),
        VerticalSpacing.small,

        Text(
          exercise['description'] ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.descriptionTextColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
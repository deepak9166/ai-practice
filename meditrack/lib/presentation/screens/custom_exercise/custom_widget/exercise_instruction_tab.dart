import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import 'exercise_description_webview.dart';

class ExerciseInstructionTab extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseInstructionTab({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'GIF & Step-by-Step Instructions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppTheme.titleTextColor,
            ),
          ),
          VerticalSpacing(),
          Container(
            width: double.infinity,
            height: 183,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              'https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbzg5NDQ2ejAwZ2ZqOGhvNjV3YzRwemtrbGM2ZHJ4eHYydW5zNGh5cCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/4bjIKBOWUnVPICCzJc/giphy.gif',
              fit: BoxFit.cover,
            ),
          ),
          VerticalSpacing(),
          SizedBox(
            height: 500,
            child: ExerciseDescriptionWebView(
              htmlContent: exercise['htmlDescription'] ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

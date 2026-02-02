import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/preview_video_player.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import 'exercise_description_webview.dart';

class ExerciseVideoTab extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseVideoTab({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final String? videoUrl = exercise['videoUrl'];

    if (videoUrl == null || videoUrl.isEmpty) {
      return const Center(child: Text('No video available'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          if (exercise['videoUrl'] != null) ...[
            Text(
              'Video Demonstration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppTheme.titleTextColor,
              ),
            ),
            VerticalSpacing.small,
            PreviewVideoPlayer(videoUrl: exercise['videoUrl']),
            VerticalSpacing(),
            SizedBox(
              height: 500,
              child: ExerciseDescriptionWebView(
                htmlContent: exercise['htmlDescription'] ?? '',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

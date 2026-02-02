import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

import 'exercise_description_webview.dart';

class ExercisePictureTabWidget extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExercisePictureTabWidget({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final List<String> images =
        (exercise['images'] as List?)?.cast<String>() ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Text(
            'Equipment Requirements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppTheme.titleTextColor,
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: List.generate(images.length, (index) {
              final isLast = index == images.length - 1;
              final showCount = isLast && (images.length - 1) > 0;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: SmartImageView(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// CENTER +COUNT (ONLY LAST IMAGE)
                        if (showCount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              '+${(images.length - 1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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

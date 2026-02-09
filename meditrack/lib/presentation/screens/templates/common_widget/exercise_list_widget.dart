import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

class ExerciseListWidget extends StatelessWidget {
  final String exerciseName;
  final String exerciseType;
  final bool isSelected;
  final bool isFavorite;
  final String? exerciseImage;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ExerciseListWidget({
    super.key,
    required this.exerciseName,
    required this.exerciseType,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.exerciseImage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: Row(
          children: [
            SmartImageView(
              isSelected
                  ? SvgImageId.tickSquare.path
                  : SvgImageId.emptySquare.path,
            ),
            HorizontalSpacing(),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(child: SmartImageView(exerciseImage)),
            ),
            HorizontalSpacing(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        exerciseName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exerciseType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            isFavorite
                ? IconButton(
                    onPressed: onFavoriteTap,
                    icon: SmartImageView(
                      isFavorite ? SvgImageId.favorite.path : '',
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

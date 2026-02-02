import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class WorkoutGroupCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDottedBorder;
  final bool showThreeDots;
  final VoidCallback? onThreeDotsTap;

  const WorkoutGroupCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.showDottedBorder = false,
    this.showThreeDots = false,
    this.onThreeDotsTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseChild = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: showDottedBorder
            ? null
            : Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SmartImageView(imagePath, radius: 50, height: 62),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );

    final cardChild = showDottedBorder
        ? DottedBorder(
            color: Colors.black,
            strokeWidth: 0.5,
            dashPattern: [4, 2],
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            child: baseChild,
          )
        : baseChild;

    final finalChild = showThreeDots
        ? Stack(
            children: [
              cardChild,
              Positioned(
                top: 8,
                right: 4,
                child: onThreeDotsTap != null
                    ? GestureDetector(
                        onTap: onThreeDotsTap,
                        child: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.black,
                      ),
              ),
            ],
          )
        : cardChild;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: showThreeDots ? null : onTap,
      child: finalChild,
    );
  }
}

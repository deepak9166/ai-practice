import 'package:flutter/material.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

import '../../../../config/svg_config.dart';

class MMGLevelCard extends StatelessWidget {
  final String imageUrl;
  final String title; // e.g., "MMG-31"
  final String description; // e.g., "Front & Lateral Shoulder on Push Day"
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onPreview; // for the + button

  const MMGLevelCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.isSelected = false,
    this.onTap,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).colorScheme.onSecondaryContainer,

        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        // borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thumbnail with + overlay
              Stack(
                children: [
                  SmartImageView(
                    radius: 9,
                    imageUrl,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: InkWell(
                      onTap: onPreview,

                      child: SmartImageView(
                        SvgImageId.preview.path,
                        height: 20,
                        width: 20,
                        radius: 40,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Trailing radio button (unselected)
              Radio<bool>(
                value: isSelected,
                groupValue: true,
                onChanged: (value) {
                  appLog('on change $value');
                  if (onTap != null) {
                    onTap!();
                  }
                }, // Read-only or handle in onTap
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MMGLevelSelectedCard extends StatelessWidget {
  final String imageUrl;
  final String title; // e.g., "MMG-31"
  final String description; // e.g., "Front & Lateral Shoulder on Push Day"

  const MMGLevelSelectedCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thumbnail with + overlay
            SmartImageView(
              radius: 9,
              imageUrl,
              width: 37,
              height: 37,
              fit: BoxFit.cover,
            ),

            const SizedBox(width: 8),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),

                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Trailing radio button (unselected)
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}

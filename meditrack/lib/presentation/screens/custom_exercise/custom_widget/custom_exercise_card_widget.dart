import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/status_label_widget.dart';

class CustomExerciseCardWidget extends StatelessWidget {
  final String title;
  final String status;
  final String mmgVersion;
  final String muscles;
  final String description;
  final String buttonIcon;
  final VoidCallback? onSeeDetail;
  final void Function(Offset details)? onTopBtnTapped;

  const CustomExerciseCardWidget({
    super.key,
    required this.title,
    required this.status,
    required this.mmgVersion,
    required this.muscles,
    required this.description,
    required this.buttonIcon,
    this.onSeeDetail,
    this.onTopBtnTapped,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onSeeDetail,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F2FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: AppTheme.titleTextColor,
                            ),
                      ),
                      HorizontalSpacing(),
                      StatusLabelWidget(status: status),
                    ],
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    final box = context.findRenderObject() as RenderBox;

                    final offset = box.localToGlobal(
                      Offset(box.size.width - 50, 40),
                    );

                    onTopBtnTapped?.call(offset);
                  },
                  child: SmartImageView(buttonIcon),
                ),
              ],
            ),
            VerticalSpacing(),
            Row(
              children: [
                SmartImageView(SvgImageId.strength.path),
                const SizedBox(width: 6),
                Text(
                  mmgVersion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.descriptionTextColor,
                  ),
                ),
                HorizontalSpacing(),
                SmartImageView(SvgImageId.templatesType.path),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    muscles,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.descriptionTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            VerticalSpacing(),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSeeDetail,
              child: Text(
                'See Detail >',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

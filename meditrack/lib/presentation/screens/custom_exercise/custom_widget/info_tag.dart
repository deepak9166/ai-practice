import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

class InfoWidget extends StatelessWidget {
  final InfoWidgetType _type;

  final String? iconPath;
  final String? text;
  final Color? titleTextColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  final String? title;
  final String? titleValue;
  final List<Map<String, String>>? titleValueList;

  const InfoWidget._({
    required InfoWidgetType type,
    this.iconPath,
    this.text,
    this.titleTextColor,
    this.backgroundColor,
    this.padding,
    this.title,
    this.titleValue,
    this.titleValueList,
  }) : _type = type;

  factory InfoWidget.tag({
    required String iconPath,
    required String text,
    Color? titleTextColor,
    Color? backgroundColor,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
  }) {
    return InfoWidget._(
      type: InfoWidgetType.tag,
      iconPath: iconPath,
      text: text,
      titleTextColor: titleTextColor,
      backgroundColor: backgroundColor,
      padding: padding,
    );
  }

  factory InfoWidget.muscleGroup({
    required String title,
    String? titleValue,
    List<Map<String, String>>? titleValueList,
  }) {
    return InfoWidget._(
      type: InfoWidgetType.muscleGroup,
      title: title,
      titleValue: titleValue,
      titleValueList: titleValueList,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case InfoWidgetType.tag:
        return _buildTag(context);
      case InfoWidgetType.muscleGroup:
        return _buildMuscleGroup(context);
    }
  }

  Widget _buildTag(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? AppTheme.backgroundContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmartImageView(iconPath!, height: 18, width: 18),
          const SizedBox(width: 6),
          Text(
            text!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: titleTextColor ?? AppTheme.descriptionTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroup(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.titleTextColor,
                fontSize: 12,
              ),
            ),
            HorizontalSpacing.smallXs,
            if (titleValue?.isNotEmpty ?? false)
              Expanded(
                child: Text(
                  titleValue ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.descriptionTextColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            if (titleValueList?.isNotEmpty ?? false)
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: titleValueList!.map((item) {
                    return RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.descriptionTextColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${item['key']} | ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppTheme.descriptionTextColor,
                            ),
                          ),
                          TextSpan(
                            text: item['value'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppTheme.titleTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

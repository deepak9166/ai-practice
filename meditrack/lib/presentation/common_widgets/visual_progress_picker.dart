import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/tooltip_widget.dart';
import 'package:super_tooltip/super_tooltip.dart';


class VisualProgressPicker extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? toolTip;
  final String? placeHolder;
  final ValueNotifier<String> imageNotifier;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;
  final double height;

  const VisualProgressPicker({
    super.key,
    this.title,
    this.subtitle,
    this.toolTip,
    this.placeHolder,
    required this.imageNotifier,
    required this.onPickImage,
    required this.onRemove,
    this.height = 92,
  });

  @override
  State<VisualProgressPicker> createState() => _VisualProgressPickerState();
}

class _VisualProgressPickerState extends State<VisualProgressPicker> {
  late SuperTooltipController _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = SuperTooltipController();
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title?.isNotEmpty ?? false)
          Text(
            widget.title ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppTheme.titleTextColor,
            ),
          ),
        if (widget.title?.isNotEmpty ?? false) VerticalSpacing.small,
        if (widget.subtitle?.isNotEmpty ?? false)
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.subtitle ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppTheme.descriptionTextColor,
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (widget.toolTip?.isNotEmpty ?? false) ...[
                const SizedBox(width: 4),
                Flexible(child: TooltipWidget(message: widget.toolTip ?? '')),
              ],
            ],
          ),

        VerticalSpacing.small,
        ValueListenableBuilder<String>(
          valueListenable: widget.imageNotifier,
          builder: (context, image, _) {
            return GestureDetector(
              onTap: widget.onPickImage,
              child: DottedBorder(
                color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                strokeWidth: 1,
                padding: EdgeInsets.all(0),
                dashPattern: const [3, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: Container(
                  height: widget.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: image.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: widget.onRemove,
                                  child: SmartImageView(SvgImageId.close.path),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _Placeholder(context, widget.placeHolder),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final BuildContext context;
  final String? placeHolder;

  const _Placeholder(this.context, this.placeHolder);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SmartImageView(SvgImageId.uploadIcon.path, height: 24, width: 24),
        const SizedBox(height: 8),
        Text(
          placeHolder ?? 'Upload image (Optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.titleTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


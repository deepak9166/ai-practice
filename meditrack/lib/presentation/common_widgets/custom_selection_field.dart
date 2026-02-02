import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/tooltip_widget.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CustomSelectionField extends StatefulWidget {
  final String label;
  final TextStyle? labelStyle;
  final String placeholder;
  final void Function(Offset position) onTap;
  final Widget? trailingIcon;
  final Color? backgroundColor;
  final String? tooltip;
  final Widget? selectedWidget;
  final bool tooltipDirectionFixed;

  const CustomSelectionField({
    super.key,
    required this.label,
    this.labelStyle,
    required this.placeholder,
    required this.onTap,
    this.trailingIcon,
    this.backgroundColor,
    this.tooltip,
    this.selectedWidget,
    this.tooltipDirectionFixed = false,
  });

  @override
  State<CustomSelectionField> createState() => _CustomSelectionFieldState();
}

class _CustomSelectionFieldState extends State<CustomSelectionField> {
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
        Row(
          children: [
            Text(
              widget.label,
              style: widget.labelStyle ??  TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (widget.tooltip?.isNotEmpty ?? false) ...[
              SizedBox(width: 4),
              TooltipWidget(
                message: widget.tooltip ?? '',
                fixDirectLeft: widget.tooltipDirectionFixed,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            widget.onTap(details.globalPosition);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color:
                  widget.backgroundColor ??
                  const Color(0xFFD0C9EA).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      widget.selectedWidget ??
                      Text(
                        widget.placeholder,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                ),
                widget.trailingIcon ??
                    const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

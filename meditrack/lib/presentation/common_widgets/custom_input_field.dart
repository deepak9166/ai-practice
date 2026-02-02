import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/tooltip_widget.dart';
import 'package:super_tooltip/super_tooltip.dart';

/// Custom Input Field Widget
///
/// A reusable text input field with consistent styling and validation.
/// Supports various input types, labels, hints, and error messages.
class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.tooltip = '',
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final String tooltip;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
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
        if (widget.label != null) ...[
          VerticalSpacing.smallXs,
          Row(
            children: [
              Text(
                widget.label ?? "",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                  fontSize: 14,
                ),
              ),
              if (widget.tooltip.isNotEmpty) ...[
                SizedBox(width: 4),
                TooltipWidget(message: widget.tooltip ?? ''),
                
              ],
            ],
          ),
          VerticalSpacing.small,
        ],
        TextFormField(
          enableInteractiveSelection: false,
          enableIMEPersonalizedLearning: false,
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

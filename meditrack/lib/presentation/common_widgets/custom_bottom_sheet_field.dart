
import 'package:flutter/material.dart';

import '../../config/svg_config.dart';
import 'smart_image_view.dart';
import 'spacing_widgets.dart';

class CustomBottomSheetField<T> extends StatelessWidget {
  const CustomBottomSheetField({
    super.key,
    this.selectedValue,
    this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.tooltip = '', 
    required this.builder, 
    this.onSelectIndex, 

  });

  final Widget Function(BuildContext ctx) builder;
  final String? label;
  final String? hint;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String tooltip;
  final Widget? selectedValue;
  final Function(dynamic callbackValue)? onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          VerticalSpacing.smallXs,
          Row(
            children: [
              Text(label ?? '', style: Theme.of(context).textTheme.titleMedium),
              if (tooltip.isNotEmpty) ...[
                const SizedBox(width: 4),
                Tooltip(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(30),
                  verticalOffset: -40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xff333333),
                    border: Border.all(
                      color: const Color(0xff606060),
                      width: 1,
                    ),
                  ),
                  triggerMode: TooltipTriggerMode.tap,
                  message: tooltip,
                  child: SmartImageView(SvgImageId.info.path),
                ),
              ],
            ],
          ),
          VerticalSpacing.small,
        ],

        InkWell(
          onTap: () {
            showBottomSheetView(context);
          },
          child: Visibility(
            visible: selectedValue == null,
            replacement: selectedValue ?? SizedBox(),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: label,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                suffixIcon: Icon(Icons.keyboard_arrow_right),

                // icon: Icon(Icons.abc_sharp),
              ),
            ),
          ),
        ),
      ],
    );
  }

  showBottomSheetView(BuildContext context) async {
  var value =  await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: builder,
    );

    if(onSelectIndex != null){
      onSelectIndex?.call(value);
    }
  }
}

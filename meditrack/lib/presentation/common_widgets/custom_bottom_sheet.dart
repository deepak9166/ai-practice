import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_model/dropdown_value_model.dart';

import '../../config/svg_config.dart';
import 'smart_image_view.dart';
import 'spacing_widgets.dart';

class CustomBottomSheet<T> extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.tooltip = '',
  });

  final List<T> items;
  final Widget Function(
    BuildContext context,
    T item,
    bool isDisabled,
    bool isSelected,
  )?
  itemBuilder;
  final T? value;
  final ValueChanged<T?> onChanged;

  final String? label;
  final String? hint;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String tooltip;

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

        /// Dropdown plugin
        DropdownSearch<DropdownValueModel>(
          items: (filter, t) =>
              items.map((e) => (e as DropdownValueModel)).toList(),

          suffixProps: DropdownSuffixProps(
            // clearButtonProps: ClearButtonProps(isVisible: true),
            dropdownButtonProps: DropdownButtonProps(
              iconClosed: Icon(Icons.keyboard_arrow_right),
              iconOpened: Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ),

          onChanged: (value) {},

          clickProps: ClickProps(),

          popupProps: PopupPropsMultiSelection.modalBottomSheet(
            fit: FlexFit.loose,
            showSelectedItems: true,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            title: AppBar(
              elevation: 2,
              leading: CloseButton(),
              title: Text("Select MMG Level"),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) =>
                itemBuilder!(context, item as T, isDisabled, isSelected),

            itemClickProps: ClickProps(
              onTapCancel: () {},
              containedInkWell: true,
            ),

            showSearchBox: false,
            // searchFieldProps: TextFieldProps(
            //   // controller: _userEditTextController,
            // ),
          ),
          compareFn: (item, selectedItem) => item.value == selectedItem.value,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: label,
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,

              // icon: Icon(Icons.abc_sharp),
            ),
          ),
          dropdownBuilder: (context, selectedItem) {
            return Text(selectedItem?.title ?? "");
          },
        ),
      ],
    );
  }
}

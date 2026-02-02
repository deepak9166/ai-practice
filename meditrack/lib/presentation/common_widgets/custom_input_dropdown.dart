import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_model/dropdown_value_model.dart';
import 'package:meditrack/presentation/common_widgets/tooltip_widget.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'spacing_widgets.dart';

class CustomDropdownInput<T> extends StatefulWidget {
  const CustomDropdownInput({
    super.key,
    required this.items,
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
  State<CustomDropdownInput<T>> createState() => _CustomDropdownInputState<T>();
}

class _CustomDropdownInputState<T> extends State<CustomDropdownInput<T>> {
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
                widget.label ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                  fontSize: 14,
                ),
              ),
              if (widget.tooltip.isNotEmpty) ...[
                const SizedBox(width: 4),
                TooltipWidget(message: widget.tooltip),
              ],
            ],
          ),
          VerticalSpacing.small,
        ],

        /// Dropdown plugin
        DropdownSearch<DropdownValueModel>(
          items: (filter, t) =>
              widget.items.map((e) => (e as DropdownValueModel)).toList(),
          suffixProps: DropdownSuffixProps(
            // clearButtonProps: ClearButtonProps(isVisible: true),
            dropdownButtonProps: DropdownButtonProps(
              iconClosed: Icon(Icons.keyboard_arrow_down_rounded),
              iconOpened: Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ),

          popupProps: PopupPropsMultiSelection.menu(
            fit: FlexFit.loose,
            showSelectedItems: true,
            itemBuilder: (context, item, isDisabled, isSelected) {
              return ListTile(
                dense: true,
                // minVerticalPadding: 0,
                visualDensity: VisualDensity(vertical: -2),
                title: Text(item.title, style: TextStyle(fontSize: 14)),
              );
            },

            showSearchBox: false,
            // searchFieldProps: TextFieldProps(
            //   // controller: _userEditTextController,
            // ),
          ),
          compareFn: (item, selectedItem) => item.value == selectedItem.value,

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: widget.hint,
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


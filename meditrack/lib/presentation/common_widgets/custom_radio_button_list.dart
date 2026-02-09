import 'package:flutter/material.dart';

import '../common_model/radio_value_model.dart';

class CustomRadioButtonList extends StatefulWidget {
  /// List of options to display (e.g., ["Distance", "Mile", "Kilometer"])
  final List<RadioValueModel> options;

  /// Currently selected value (can be null at start)
  final RadioValueModel? initialValue;

  /// Called when user selects a new option
  final ValueChanged<RadioValueModel>? onChanged;

  const CustomRadioButtonList({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<CustomRadioButtonList> createState() => _CustomRadioButtonListState();
}

class _CustomRadioButtonListState extends State<CustomRadioButtonList> {
  late RadioValueModel? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue; // Start with initial value or null
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // spacing: 2,
      // alignment: WrapAlignment.spaceBetween,
      // runAlignment: WrapAlignment.spaceBetween,

      // direction: Axis.horizontal,
      // crossAxisAlignment: WrapCrossAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...widget.options.map((item) {
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<RadioValueModel>(
                  value: item,
                  groupValue: _selectedValue,
                  visualDensity: VisualDensity(horizontal: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (RadioValueModel? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                      widget.onChanged?.call(newValue); // Notify parent
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 10),
                Text(
                  item.title,
                  style: _selectedValue?.value == null
                      ? TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryFixedVariant,
                        )
                      : TextStyle(
                          fontSize: 14,
                          color:
                              _selectedValue?.value == item.value &&
                                  (_selectedValue?.value ?? "").isNotEmpty
                              ? null
                              : Theme.of(
                                  context,
                                ).colorScheme.onSecondaryFixedVariant,
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

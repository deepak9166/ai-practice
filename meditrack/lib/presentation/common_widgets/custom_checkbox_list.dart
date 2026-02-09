import 'package:flutter/material.dart';

import '../common_model/checkbox_value_model.dart';

class CustomCheckboxList extends StatefulWidget {
  final List<CheckBoxValueModel> data;
  final bool showOptionRow;
  final ValueChanged<CheckBoxValueModel> onChanged;
  const CustomCheckboxList({
    super.key,
    required this.data,
    required this.showOptionRow,
    required this.onChanged,
  });

  @override
  State<CustomCheckboxList> createState() => _CustomCheckboxListState();
}

class _CustomCheckboxListState extends State<CustomCheckboxList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.spaceBetween,
      spacing: 30,
      children: [
        for (var item in widget.data)
          Visibility(
            visible: !widget.showOptionRow,
            replacement: Row(
              children: [
                Text(item.title, style: TextTheme.of(context).bodyMedium),
                Checkbox(
                  splashRadius: 4,
                  activeColor: Theme.of(context).primaryColor,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  value: item.value,
                  onChanged: (value) {
                    item.value = !item.value;
                    widget.onChanged(item);
                    setState(() {});
                  },
                ),
              ],
            ),
            child: Column(
              children: [
                Text(item.title),
                Checkbox(
                  splashRadius: 4,
                  activeColor: Theme.of(context).primaryColor,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  value: item.value,
                  onChanged: (value) {
                    item.value = !item.value;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

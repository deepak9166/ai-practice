import 'package:flutter/material.dart';
import '../../../../config/svg_config.dart';
import '../../../common_widgets/smart_image_view.dart';
import 'exercise_picker_helper.dart';

class ExerciseInputField extends StatelessWidget {
  final String label;
  final String secondaryLabel;
  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final bool isPickerEnabled;
  final String? pickerType; // 'reps' or 'weight'
  final ValueChanged<String>? onPickerValueSelected;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ExerciseInputField({
    super.key,
    required this.label,
    required this.secondaryLabel,
    required this.controller,
    this.decoration,
    this.keyboardType = TextInputType.number,
    this.isPickerEnabled = false,
    this.pickerType,
    this.onPickerValueSelected,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 114,
              child: Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    secondaryLabel,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 48 - ((pickerType == 'reps') ? 48 : 0)),
            if (pickerType == 'reps') ...[
              IconButton(
                onPressed: onDecrement,
                icon: SmartImageView(
                  SvgImageId.minus.path,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
            SizedBox(
              width: 50,
              height: 20,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                readOnly: isPickerEnabled,
                onTap: isPickerEnabled
                    ? () async {
                        String? selectedValue;
                        if (pickerType == 'reps') {
                          selectedValue =
                              await ExercisePickerHelper.showRepsPicker(
                                context,
                                controller.text,
                              );
                        } else if (pickerType == 'weight') {
                          selectedValue =
                              await ExercisePickerHelper.showWeightPicker(
                                context,
                                controller.text,
                              );
                        }
                        if (selectedValue != null) {
                          controller.text = selectedValue;
                          onPickerValueSelected?.call(selectedValue);
                        }
                      }
                    : null,
                style: const TextStyle(fontSize: 12),
                decoration: decoration ?? _getInputDecoration(),
              ),
            ),
            if (pickerType == 'reps') ...[
              IconButton(
                onPressed: onIncrement,
                icon: SmartImageView(
                  SvgImageId.plus.path,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

InputDecoration _getInputDecoration() {
  return InputDecoration(
    fillColor: Color.fromRGBO(243, 243, 243, 1),
    contentPadding: const EdgeInsets.all(2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 0.5),
    ),
  );
}

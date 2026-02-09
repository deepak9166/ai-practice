import 'package:flutter/material.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/screens/profile_qna/custom_value_picker_dialog.dart';

class ExercisePickerHelper {
  static Future<String?> showRepsPicker(
    BuildContext context,
    String currentValue,
  ) async {
    final pickerValues = List.generate(100, (index) => index + 1);
    final initialValue = int.tryParse(currentValue) ?? 1;
    String? selectedValue;
    await CustomValuePickerDialog.show(
      context: context,
      title: 'select reps',
      mainValues: pickerValues,
      decimalValues: [0],
      units: ['Reps'],
      initialMainValue: initialValue,
      showDecimal: false,
      onSave: (value) {
        selectedValue = value.split(' ')[0];
        appLog('selected reps: $selectedValue');
      },
    );
    return selectedValue;
  }

  static Future<String?> showWeightPicker(
    BuildContext context,
    String currentValue,
  ) async {
    final pickerValues = List.generate(200, (index) => index + 1);
    final parts = currentValue.split(' ');
    final numPart = parts.isNotEmpty ? parts[0] : '';
    final numParts = numPart.split('.');
    final initialValue = int.tryParse(numParts[0]) ?? 200;
    final initialDecimal = numParts.length > 1
        ? int.tryParse(numParts[1]) ?? 0
        : 0;
    String? selectedValue;
    await CustomValuePickerDialog.show(
      context: context,
      title: 'Body Weight (kg)',
      mainValues: pickerValues,
      decimalValues: List.generate(10, (index) => index * 10),
      units: ['lb', 'kg'],
      initialMainValue: initialValue,
      initialDecimalValue: initialDecimal,
      initialUnitIndex: 1,
      showDecimal: true,
      onSave: (value) {
        selectedValue = value.split(' ')[0];
        appLog('selected weight: $selectedValue');
      },
    );
    return selectedValue;
  }
}

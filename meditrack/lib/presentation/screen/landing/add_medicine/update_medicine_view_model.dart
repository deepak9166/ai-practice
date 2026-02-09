import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/extension/toast_helper.dart';

import '../../../../data/local/app_database.dart';
import '../../../common_model/dropdown_value_model.dart';
import '../../base/base_view_model.dart';

class UpdateMedicineViewModel extends BaseViewModel {
  final AppDatabase db;
  final int medicineId;

  UpdateMedicineViewModel({required this.db, required this.medicineId});

  TextEditingController medicineNameTextC = TextEditingController();
  int? typeTextC;
  TextEditingController totalQuantity = TextEditingController();
  bool isLowAlert = false;
  DropdownValueModel<int>? selectedType;

  Future<void> loadMedicine() async {
    final medicine = await db.getMedicineDetail(medicineId);
    if (medicine == null) return;
    final types = await db.getAllMedicinesType();
    final match = types.where((t) => t.id == medicine.typeId).toList();
    final type = match.isNotEmpty ? match.first : null;

    medicineNameTextC.text = medicine.name;
    typeTextC = medicine.typeId;
    totalQuantity.text = medicine.totalQuantity.toString();
    isLowAlert = medicine.lowStockAlert;
    selectedType = type != null
        ? DropdownValueModel<int>(title: type.name, value: type.id)
        : null;
    notifyListeners();
  }

  Future<List<DropdownValueModel<int>>> getAllMedicinesType() async {
    final list = await db.getAllMedicinesType();
    return list
        .map(
          (e) => DropdownValueModel<int>(title: e.name, value: e.id),
        )
        .toList();
  }

  Future<void> saveMedicine(BuildContext context) async {
    if (medicineNameTextC.text.trim().isEmpty) {
      context.showWarning('Please enter medicine name!');
      return;
    }
    if (typeTextC == null) {
      context.showWarning('Please select type!');
      return;
    }
    if (totalQuantity.text.trim().isEmpty) {
      context.showWarning('Please enter total quantity!');
      return;
    }

    await db.updateMedicine(
      medicineId,
      MedicinesCompanion(
        name: Value(medicineNameTextC.text.trim()),
        typeId: Value(typeTextC!),
        totalQuantity: Value(int.tryParse(totalQuantity.text) ?? 0),
        lowStockAlert: Value(isLowAlert),
      ),
    );
    context.showSuccess('Medicine updated successfully!');
    context.hideKeyboard();
    Navigator.of(context).pop(true);
  }
}

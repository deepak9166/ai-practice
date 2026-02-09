import 'package:flutter/material.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';

import '../../../../data/local/app_database.dart';
import '../../../common_model/dropdown_value_model.dart';
import '../../base/base_view_model.dart';

class AddMedicineViewModel extends BaseViewModel {
  final AppDatabase db;
  AddMedicineViewModel({required this.db});

  TextEditingController medicineNameTextC = TextEditingController();
  int? typeTextC;
  TextEditingController totalQuantity = TextEditingController();
  bool isLowAlert = false;

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

    final data = MedicinesCompanion.insert(
      name: medicineNameTextC.text.trim(),
      typeId: typeTextC!,
      lowStockAlert: isLowAlert,
      totalQuantity: int.tryParse(totalQuantity.text) ?? 0,
    );
    await db.addMedicine(data);
    context.showSuccess('Medicine added successfully!');
    context.hideKeyboard();
    _clearForm();
  }

  _clearForm() {
    medicineNameTextC.text = "";
    totalQuantity.text = "";
    typeTextC = null;
    isLowAlert = false;
  }

  Future<List<DropdownValueModel<int>>> getAllMedicinesType() async {
    var list = await db.getAllMedicinesType();

    return list
        .map(
          (element) =>
              DropdownValueModel<int>(title: element.name, value: element.id),
        )
        .toList();
  }

  Future<List<String>> fetchMedicines(String query) async {
    var list = await db.searchMedicinesByName(query);
    appLog('total medicines found: ${list.length}');
    return list.map((medicine) => medicine.name).toList();
  }

  Future<int?> getMedicineIdByName(String name) async {
    final medicine = await db.getMedicineByName(name);
    return medicine?.id;
  }

  void clearForm() {
    medicineNameTextC.text = "";
    totalQuantity.text = "";
    typeTextC = null;
    isLowAlert = false;
  }
}

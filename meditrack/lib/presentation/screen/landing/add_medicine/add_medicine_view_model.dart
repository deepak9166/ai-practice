import 'package:drift/drift.dart';
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
    appLog('medicineNameTextC ${medicineNameTextC.text}');
    appLog('typeTextC ${typeTextC}');

    if (totalQuantity.text.trim().isEmpty) {
      context.showWarning('Please enter name!');
      return;
    }

    if (typeTextC == null) {
      context.showWarning('Please enter type!');
      return;
    }

    var data = MedicinesCompanion.insert(
      name: medicineNameTextC.text,
      typeId: typeTextC!,
      lowStockAlert: isLowAlert,
      totalQuantity: int.tryParse(totalQuantity.text) ?? 0,
    );

    print("data ${data}");
    var result = await db.addMedicine(data);

    context.showSuccess('Medicine Added Successfully!');
    context.hideKeyboard();

    _clearForm();

    // appLog('result $result');
  }

  _clearForm(){
    medicineNameTextC.text = "";
    totalQuantity.text= "";

  }

  Future<List<DropdownValueModel>> getAllMedicinesType() async {
    var list = await db.getAllMedicinesType();

    return list
        .map(
          (element) =>
              DropdownValueModel<int>(title: element.name, value: element.id),
        )
        .toList();
  }
}

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/log/app_logs.dart';

import '../../../../data/local/app_database.dart';
import '../../base/base_view_model.dart';

class AddMedicineViewModel extends BaseViewModel {
  final AppDatabase db;
  AddMedicineViewModel({required this.db});

  TextEditingController medicineNameTextC = TextEditingController();
  TextEditingController typeTextC = TextEditingController();
  double doseTextC = 0.0;
  TextEditingController frequencyTextC = TextEditingController();
  DateTime? startDateTextC;
  TextEditingController timeTextC = TextEditingController();

  ValueNotifier<bool> isSetReminder = ValueNotifier(false);

  Future<void> saveMedicine(BuildContext context) async {
    appLog('medicineNameTextC ${medicineNameTextC.text}');
    appLog('typeTextC ${typeTextC.text}');
    appLog('doseTextC ${doseTextC}');
    appLog('frequencyTextC ${frequencyTextC.text}');
    appLog('startDateTextC ${startDateTextC}');
    appLog('timeTextC ${timeTextC.text}');
    appLog('isSetReminder ${isSetReminder}');

    var data = MedicinesCompanion.insert(
      dose: doseTextC,
      endDate: Value(null),
      frequency: frequencyTextC.text,
      name: medicineNameTextC.text,
      startDate: startDateTextC!,
      times: "[]",
      type: typeTextC.text,
    );
    var result = await db.addMedicine(data);

    appLog('result $result');
  }
}

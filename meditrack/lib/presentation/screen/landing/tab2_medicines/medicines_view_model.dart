import 'package:flutter/material.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

import '../../../common_model/dropdown_value_model.dart';
import '../../base/screen_state.dart';

class MedicinesViewModel extends BaseViewModel {
  final AppDatabase db;
  MedicinesViewModel({required this.db});

  ValueNotifier<bool> isSetReminder = ValueNotifier(false);
  TextEditingController startDateTextC = TextEditingController();
  TextEditingController timeTextC = TextEditingController();

  Stream<List<Medicine>> getAlMedicine() {
    return db.watchAllMedicines();
  }

  Future<List<MedicinesRepeatData>> fetchRepeat() async {
    return db.getAllMedicinesRepeat();
  }
}

class MedicinesDetailViewModel extends BaseViewModel {
  final AppDatabase db;
  final int medicineId;
  MedicinesDetailViewModel({required this.db, required this.medicineId}) {
    fetchMedicineDetail(medicineId);
  }

  ValueNotifier<bool> isSetReminder = ValueNotifier(false);
  TextEditingController startDateTextC = TextEditingController();
  TextEditingController timeTextC = TextEditingController();

  DropdownValueModel? selectedValue;

  Medicine? medicineDetail;

  Future<List<DropdownValueModel>> fetchRepeat() async {
    var list = await db.getAllMedicinesRepeat();

    return list
        .map(
          (element) =>
              DropdownValueModel(title: element.name, value: element.id),
        )
        .toList();
  }

  Future<void> fetchMedicineDetail(int medicineId) async {
    changeScreenState(ScreenState.apiProgress);

    medicineDetail = await db.getMedicineDetail(medicineId);

    changeScreenState(ScreenState.content);
  }

  Future<void> addReminder(DateTime selectedDate, int repeatedValue, BuildContext context) async {
    var data = IntakeHistoriesCompanion.insert(
      medicineId: medicineId,
      intakeTime: selectedDate,
      repeatType: repeatedValue,
      status: "Upcoming",
    );
    await db.logIntake(data);

    appLog('Reminder Set Successfully!');
    context.showSuccess('Reminder Set Successfully!');

  }

  Stream<List<IntakeHistory>> fetchLogs()  {

  return  db.watchAllLogs();
  }
}

import 'package:flutter/material.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

import '../../../../core/service/notification_service.dart';
import '../../../common_model/dropdown_value_model.dart';
import '../../base/screen_state.dart';
import 'hepler/medicine_remider_time.dart';

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
  final LocalNotificationService notificationService;
  MedicinesDetailViewModel({
    required this.db,
    required this.medicineId,
    required this.notificationService,
  }) {
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

  Future<void> addReminder(
    DateTime selectedDate,
    int repeatedValue,
    BuildContext context,
  ) async {
    var isSetAlarm = await setNotification(selectedDate, medicineId);

    if (isSetAlarm == false) {
      context.showError('Reminder Setup failed!');
      return;
    }
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

  Future<bool> setNotification(DateTime time, int medicineId) async {
    try {
      final notificationId = NotificationIdHelper.generate(
        medicineId: medicineId,
        selectedTime: time,
      );

      if (time.isBefore(DateTime.now())) {
        debugPrint('❌ DateTime is in the past');
        return false;
      }

      await notificationService.scheduleMedicineReminder(
        id: notificationId,
        title: 'Medicine Reminder 💊',
        body: 'Time to take ${medicineDetail?.name}',
        dateTime: time,
        payload: medicineId.toString(),
      );

      appLog('💊 Reminder set on $time');

      return true;
    } catch (e) {
      appLog("Error on set notification $e");
      return false;
    }
  }

  void demoNotification() {
    notificationService.showNotificationInApp();
  }

  Stream<List<IntakeHistory>> fetchLogs() {
    return db.watchAllLogs(medicineId);
  }
}

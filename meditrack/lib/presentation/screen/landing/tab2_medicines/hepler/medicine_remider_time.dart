import 'package:meditrack/log/app_logs.dart';

class MedicineReminderTime {
  final int medicineId;
  final int timeIndex; // 0,1,2...
  final DateTime dateTime;

  MedicineReminderTime({
    required this.medicineId,
    required this.timeIndex,
    required this.dateTime,
  });
}

class NotificationIdHelper {
  static int generate({
    required int medicineId,
    required DateTime selectedTime,
  }) {
    var id =
        "$medicineId${selectedTime.day}${selectedTime.hour}${selectedTime.minute}";
    // return (medicineId * 100000) +
    //     (selectedTime.millisecondsSinceEpoch % 100000);
    appLog(" $medicineId ID GENERATE $id");
    return int.parse(id);
  }
}

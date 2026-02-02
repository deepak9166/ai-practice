import 'package:flutter/material.dart';
import 'package:meditrack/log/app_logs.dart';

import '../../base/base_view_model.dart';

class AddMedicineViewModel extends BaseViewModel {

  TextEditingController medicineNameTextC = TextEditingController();
  TextEditingController typeTextC = TextEditingController();
  TextEditingController doseTextC = TextEditingController();
  TextEditingController frequencyTextC = TextEditingController();
  TextEditingController startDateTextC = TextEditingController();
  TextEditingController timeTextC = TextEditingController();

  ValueNotifier<bool> isSetReminder = ValueNotifier(false);

 Future<void> saveMedicine(BuildContext context) async {
appLog('medicineNameTextC ${medicineNameTextC.text}');
appLog('typeTextC ${typeTextC.text}');
appLog('doseTextC ${doseTextC.text}');
appLog('frequencyTextC ${frequencyTextC.text}');
appLog('startDateTextC ${startDateTextC.text}');
appLog('timeTextC ${timeTextC.text}');
appLog('isSetReminder ${isSetReminder}');

}

}

import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/providers/local_storage_provider.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

import '../../../data/local/app_database.dart';
import '../base/screen_state.dart';

class LandingViewModel extends BaseViewModel {
  final AppDatabase db;
  LandingViewModel({required this.authStateObj, required this.db}) {
    _configSetup();
  }

  final AuthState authStateObj;

  AuthState get authState => authStateObj;

  callApi() async {
    changeScreenState(ScreenState.apiProgress);
    await Future.delayed(Duration(seconds: 4));
    changeScreenState(ScreenState.content);
  }

  _configSetup() async {
    /// Medicine Type Added
    await medicineTypeSetup();
    await medicineDoseSetup();
    await medicineRepeatSetup();

    // Dose Added
  }

  Future<void> medicineTypeSetup() async {
    bool isMedicineTypeAdded = await db.isMedicineTypesInserted();
    if (isMedicineTypeAdded) {
      appLog('Medicine Type already added');
      return;
    }
    List<MedicinesTypesCompanion> dropdownListMedicineType = [
      MedicinesTypesCompanion.insert(name: 'Tablet'),
      MedicinesTypesCompanion.insert(name: 'Capsule'),
      MedicinesTypesCompanion.insert(name: 'Syrup'),
      MedicinesTypesCompanion.insert(name: 'Injection'),
      MedicinesTypesCompanion.insert(name: 'Drops (eye / ear / nasal)'),
      MedicinesTypesCompanion.insert(name: 'Total Reps Per Muscle Group'),
      MedicinesTypesCompanion.insert(name: 'Cream / Ointment'),
    ];

    await db.addMedicineTypes(dropdownListMedicineType);
  }

  Future<void> medicineDoseSetup() async {
    bool isMedicineDoseAdded = await db.isMedicineDoseInserted();
    if (isMedicineDoseAdded) {
      appLog('Medicine Dose already added');
      return;
    }
    List<MedicinesDoseCompanion> dropdownListMedicinDose = [
      MedicinesDoseCompanion.insert(name: '1', doseValue: 1.0),
      MedicinesDoseCompanion.insert(name: '2', doseValue: 2.0),
      MedicinesDoseCompanion.insert(name: '3', doseValue: 3.0),
      MedicinesDoseCompanion.insert(name: '4', doseValue: 4.0),
      MedicinesDoseCompanion.insert(name: '1/2', doseValue: 0.50),
      MedicinesDoseCompanion.insert(name: '1/4', doseValue: 0.25),
    ];

    await db.addMedicineDose(dropdownListMedicinDose);
  }

  Future<void> medicineRepeatSetup() async {

    bool isMedicineRepeatAdded = await db.isMedicineRepeatInserted();
    if (isMedicineRepeatAdded) {
      appLog('Medicine Repeat already added');
      return;
    }
    List<MedicinesRepeatCompanion> dropdownListMedicinRepeat = [
      MedicinesRepeatCompanion.insert(name: 'Never', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Every Day', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Monday to Friday', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Every Week', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Every Month', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Every Year', meta: ''),
      MedicinesRepeatCompanion.insert(name: 'Custom', meta: ''),
    ];

    await db.addMedicineRepeat(dropdownListMedicinRepeat);
  }
}

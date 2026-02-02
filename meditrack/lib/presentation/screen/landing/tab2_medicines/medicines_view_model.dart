import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

class MedicinesViewModel extends BaseViewModel {
  final AppDatabase db;
  MedicinesViewModel({required this.db});

  List<Medicine> medicineList = [];
  fetchMedicineList() async {
    var list = await db.getAllMedicines();

    medicineList = list;
  }
}

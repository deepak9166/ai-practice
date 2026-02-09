import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_model/exercise_model.dart';

import '../../base/base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  final AppDatabase db;
  HomeViewModel({required this.db});

  Stream<List<MedicineModel>> get todayMedicinesStream => db
      .watchAllIntakeHistories()
      .asyncMap(_toMedicineModels)
      .map(_filterToday);

  Stream<List<MedicineModel>> get upcomingMedicinesStream => db
      .watchAllIntakeHistories()
      .asyncMap(_toMedicineModels)
      .map(_filterUpcoming);

  Future<List<MedicineModel>> _toMedicineModels(
    List<IntakeHistory> intakes,
  ) async {
    if (intakes.isEmpty) return [];
    final medicines = await db.getAllMedicines();
    final types = await db.getAllMedicinesType();
    final medicineMap = {for (var m in medicines) m.id: m};
    final typeMap = {for (var t in types) t.id: t.name};
    return intakes
        .map((intake) {
          final medicine = medicineMap[intake.medicineId];
          if (medicine == null) return null;
          final typeName = typeMap[medicine.typeId] ?? '';
          return MedicineModel(
            name: medicine.name,
            date: intake.intakeTime.toIso8601String(),
            type: typeName,
            status: intake.status,
            medicineId: medicine.id,
            intakeId: intake.id,
          );
        })
        .whereType<MedicineModel>()
        .toList();
  }

  List<MedicineModel> _filterToday(List<MedicineModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    return list.where((m) {
      if (m.status == 'Taken') return false;
      try {
        final dt = DateTime.parse(m.date);
        return !dt.isBefore(today) && dt.isBefore(tomorrow);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> markIntakeAsTaken(int intakeId) async {
    final intake = await db.getIntakeById(intakeId);
    if (intake == null) return;
    await db.updateIntakeStatus(intakeId, 'Taken');
    final qty = (intake.doseValue ?? 1.0).round().clamp(1, 999);
    appLog('Marking intake as taken: $intakeId, qty: $qty');
    await db.reduceStock(intake.medicineId, qty);
  }

  List<MedicineModel> _filterUpcoming(List<MedicineModel> list) {
    final now = DateTime.now();
    return list.where((m) {
      try {
        return DateTime.parse(m.date).isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();
  }
}

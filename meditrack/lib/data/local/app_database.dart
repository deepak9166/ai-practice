// app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/medicine_dose.dart';
import 'tables/medicine_repeat.dart';
import 'tables/medicine_types.dart';
import 'tables/medicines.dart';
import 'tables/stocks.dart';
import 'tables/expenses.dart';
import 'tables/intake_history.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Medicines,
    MedicinesTypes,
    MedicinesDose,
    MedicinesRepeat,
    Stocks,
    Expenses,
    IntakeHistories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // -------- Medicine CRUD --------

  Future<int> addMedicine(MedicinesCompanion data) =>
      into(medicines).insert(data);

  Future<List<Medicine>> getAllMedicines() => select(medicines).get();

Future<Medicine?> getMedicineDetail(int id) {
  return (select(medicines)
        ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();
}
  // Stream
  Stream<List<Medicine>> watchAllMedicines() => select(medicines).watch();

  // -------- Medicine Type --------

  Future<void> addMedicineTypes(List<MedicinesTypesCompanion> data) async {
    await batch((batch) {
      batch.insertAll(medicinesTypes, data);
    });
  }

  Future<bool> isMedicineTypesInserted() async {
    final countExp = medicinesTypes.id.count();
    final query = selectOnly(medicinesTypes)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)! > 0;
  }

  Future<List<MedicinesType>> getAllMedicinesType() =>
      select(medicinesTypes).get();

  // -------- Medicine Dose --------

  Future<void> addMedicineDose(List<MedicinesDoseCompanion> data) async {
    await batch((batch) {
      batch.insertAll(medicinesDose, data);
    });
  }

  Future<bool> isMedicineDoseInserted() async {
    final countExp = medicinesDose.id.count();
    final query = selectOnly(medicinesDose)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)! > 0;
  }

  Future<List<MedicinesDoseData>> getAllMedicinesDose() =>
      select(medicinesDose).get();

  // -------- Medicine Repeat --------

  Future<void> addMedicineRepeat(List<MedicinesRepeatCompanion> data) async {
    await batch((batch) {
      batch.insertAll(medicinesRepeat, data);
    });
  }

  Future<bool> isMedicineRepeatInserted() async {
    final countExp = medicinesRepeat.id.count();
    final query = selectOnly(medicinesRepeat)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)! > 0;
  }

  Future<List<MedicinesRepeatData>> getAllMedicinesRepeat() =>
      select(medicinesRepeat).get();

  // -------- Stock --------

  Future<void> addStock(StocksCompanion data) => into(stocks).insert(data);

  Future<void> reduceStock(int medicineId, int qty) async {
    await customUpdate(
      'UPDATE stocks SET remaining_quantity = remaining_quantity - ? WHERE medicine_id = ?',
      variables: [Variable.withInt(qty), Variable.withInt(medicineId)],
    );
  }

  // -------- Expense --------

  Future<void> addExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Future<List<Expense>> getExpenses(int medicineId) =>
      (select(expenses)..where((e) => e.medicineId.equals(medicineId))).get();

  // -------- Intake History --------

  Future<void> logIntake(IntakeHistoriesCompanion data) =>
      into(intakeHistories).insert(data);


        Stream<List<IntakeHistory>> watchAllLogs() => select(intakeHistories).watch();

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'meditrack_db7.sqlite'));
    return NativeDatabase(file);
  });
}

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
import 'tables/expenses.dart';
import 'tables/intake_history.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Medicines,
    MedicinesTypes,
    MedicinesDose,
    MedicinesRepeat,
    Expenses,
    IntakeHistories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(intakeHistories, intakeHistories.doseValue);
      }
    },
  );

  // -------- Medicine CRUD --------

  Future<int> addMedicine(MedicinesCompanion data) =>
      into(medicines).insert(data);

  Future<List<Medicine>> getAllMedicines() => select(medicines).get();

  Future<Medicine?> getMedicineDetail(int id) {
    return (select(
      medicines,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<Medicine>> searchMedicinesByName(String query) =>
      (select(medicines)..where((tbl) => tbl.name.like('%$query%'))).get();

  Future<Medicine?> getMedicineByName(String name) async {
    final list =
        await (select(medicines)
              ..where((tbl) => tbl.name.equals(name))
              ..limit(1))
            .get();
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> updateMedicine(int id, MedicinesCompanion data) async {
    await (update(medicines)..where((tbl) => tbl.id.equals(id))).write(data);
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

  Future<Medicine?> getStockByMedicineId(int medicineId) => (select(
    medicines,
  )..where((m) => m.id.equals(medicineId))).getSingleOrNull();

  Stream<Medicine?> watchStockByMedicineId(int medicineId) => (select(
    medicines,
  )..where((m) => m.id.equals(medicineId))).watchSingleOrNull();

  Future<void> reduceStock(int medicineId, int qty) async {
    final stock = await getStockByMedicineId(medicineId);
    if (stock != null) {
      await customUpdate(
        'UPDATE medicines SET total_quantity = max(0, total_quantity - ?) WHERE id = ?',
        variables: [Variable.withInt(qty), Variable.withInt(medicineId)],
      );
    } else {
      await customUpdate(
        'UPDATE medicines SET total_quantity = max(0, total_quantity - ?) WHERE id = ?',
        variables: [Variable.withInt(qty), Variable.withInt(medicineId)],
      );
    }
  }

  // -------- Expense --------

  Future<void> addExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Future<List<Expense>> getExpenses(int medicineId) =>
      (select(expenses)..where((e) => e.medicineId.equals(medicineId))).get();

  Future<void> updateExpense(int id, ExpensesCompanion data) async {
    await (update(expenses)..where((e) => e.id.equals(id))).write(data);
  }

  // -------- Intake History --------

  Future<void> logIntake(IntakeHistoriesCompanion data) =>
      into(intakeHistories).insert(data);

  Stream<List<IntakeHistory>> watchAllLogs(int medicineId) => (select(
    intakeHistories,
  )..where((e) => e.medicineId.equals(medicineId))).watch();

  Stream<List<IntakeHistory>> watchAllIntakeHistories() => (select(
    intakeHistories,
  )..orderBy([(t) => OrderingTerm.asc(t.intakeTime)])).watch();

  Future<void> updateIntakeStatus(int id, String status) async {
    await (update(intakeHistories)..where((t) => t.id.equals(id))).write(
      IntakeHistoriesCompanion(status: Value(status)),
    );
  }

  Future<IntakeHistory?> getIntakeById(int id) => (select(
    intakeHistories,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'meditrack_db9.sqlite'));
    return NativeDatabase(file);
  });
}

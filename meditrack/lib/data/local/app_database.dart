// app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/medicines.dart';
import 'tables/stocks.dart';
import 'tables/expenses.dart';
import 'tables/intake_history.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Medicines, Stocks, Expenses, IntakeHistories],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // -------- Medicine CRUD --------

  Future<int> addMedicine(MedicinesCompanion data) =>
      into(medicines).insert(data);

  Future<List<Medicine>> getAllMedicines() =>
      select(medicines).get();

  // -------- Stock --------

  Future<void> addStock(StocksCompanion data) =>
      into(stocks).insert(data);

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'meditrack.sqlite'));
    return NativeDatabase(file);
  });
}

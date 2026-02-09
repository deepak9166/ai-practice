// intake_history.dart
import 'package:drift/drift.dart';
import 'package:meditrack/data/local/tables/medicine_repeat.dart';
import 'medicines.dart';

class IntakeHistories extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get medicineId => integer().references(Medicines, #id)();

  DateTimeColumn get intakeTime => dateTime()();

  IntColumn get repeatType => integer().references(MedicinesRepeat, #id)();

  TextColumn get status => text()(); // Taken / Missed/ Upcoming

  RealColumn get doseValue => real().nullable()(); // dose units to deduct from stock when taken
}

// medicines.dart
import 'package:drift/drift.dart';

class MedicinesDose extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get doseValue => real()();

}

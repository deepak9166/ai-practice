// medicines.dart
import 'package:drift/drift.dart';
import 'package:meditrack/data/local/tables/medicine_types.dart';

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  IntColumn get typeId => integer().references(MedicinesTypes, #id)();

  IntColumn get totalQuantity=> integer()(); // total medicine

  BoolColumn get lowStockAlert=> boolean()(); // low stock alert

}

// medicines.dart
import 'package:drift/drift.dart';

class MedicinesTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

}

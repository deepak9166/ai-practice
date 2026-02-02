// medicines.dart
import 'package:drift/drift.dart';

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get type => text()(); // Tablet, Syrup

  RealColumn get dose => real()(); // 1 tablet, 5 ml

  TextColumn get frequency => text()(); // once, twice, custom

  TextColumn get times =>
      text()(); // Stored as JSON ["08:00","20:00"]

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();
}

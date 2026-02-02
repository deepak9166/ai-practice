// intake_history.dart
import 'package:drift/drift.dart';
import 'medicines.dart';

class IntakeHistories extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get medicineId =>
      integer().references(Medicines, #id)();

  DateTimeColumn get intakeTime => dateTime()();

  TextColumn get status => text()(); // Taken / Missed
}
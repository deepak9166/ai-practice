// expenses.dart
import 'package:drift/drift.dart';
import 'medicines.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get medicineId =>
      integer().references(Medicines, #id)();

  IntColumn get quantityBought => integer()();

  RealColumn get pricePaid => real()();

  RealColumn get pricePerUnit => real()();

  DateTimeColumn get purchaseDate => dateTime()();
}

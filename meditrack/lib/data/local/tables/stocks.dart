// stocks.dart
import 'package:drift/drift.dart';
import 'medicines.dart';

class Stocks extends Table {
  IntColumn get medicineId =>
      integer().references(Medicines, #id)();

  IntColumn get totalQuantity => integer()();

  IntColumn get remainingQuantity => integer()();

  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {medicineId};
}

import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

enum ExpenseFilter { monthly, yearly, lifetime }

class ExpenseWithMedicineName {
  final Expense expense;
  final String medicineName;

  ExpenseWithMedicineName({required this.expense, required this.medicineName});
}

class ExpensesViewModel extends BaseViewModel {
  final AppDatabase db;
  ExpensesViewModel({required this.db});

  Stream<List<ExpenseWithMedicineName>> watchExpenses(ExpenseFilter filter) {
    return db.watchAllExpenses().asyncMap((expenses) async {
      final medicines = await db.getAllMedicines();
      final medMap = {for (var m in medicines) m.id: m.name};

      final now = DateTime.now();
      DateTime? from;
      DateTime? to;

      if (filter == ExpenseFilter.monthly) {
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      } else if (filter == ExpenseFilter.yearly) {
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31, 23, 59, 59);
      }

      return expenses
          .where((e) {
            if (from != null && e.purchaseDate.isBefore(from)) return false;
            if (to != null && e.purchaseDate.isAfter(to)) return false;
            return true;
          })
          .map(
            (e) => ExpenseWithMedicineName(
              expense: e,
              medicineName: medMap[e.medicineId] ?? 'Unknown',
            ),
          )
          .toList();
    });
  }

  /// Monthly expense total for home dashboard
  Future<double> getMonthlyTotal() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final expenses = await db.getAllExpenses(from: from, to: to);
    return expenses.fold<double>(0.0, (sum, e) => sum + e.pricePaid);
  }
}

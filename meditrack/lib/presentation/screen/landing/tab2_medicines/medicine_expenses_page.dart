import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

import '../../../common_widgets/spacing_widgets.dart';
import 'add_expense_bottom_sheet.dart';
import 'medicines_view_model.dart';

class MedicineExpensesPage extends ConsumerStatefulWidget {
  final int medicineId;

  const MedicineExpensesPage({super.key, required this.medicineId});

  @override
  ConsumerState<MedicineExpensesPage> createState() => _MedicineExpensesPageState();
}

class _MedicineExpensesPageState
    extends BaseConsumerState<MedicineExpensesPage, MedicinesDetailViewModel> {
  Future<List<Expense>>? _expensesFuture;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = viewModel.getExpenses();
    });
  }

  void _showExpenseBottomSheet(Expense? expense) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddExpenseBottomSheet(
        viewModel: viewModel,
        expense: expense,
        onSaved: _refreshExpenses,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        actions: [
          IconButton(
            onPressed: () => _showExpenseBottomSheet(null),
            icon: Icon(Icons.add),
            tooltip: 'Add expense',
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: snapshot.hasError
                  ? Text('Error loading expenses')
                  : CircularProgressIndicator(),
            );
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No expenses yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    VerticalSpacing.medium,
                    FilledButton.icon(
                      onPressed: () => _showExpenseBottomSheet(null),
                      icon: Icon(Icons.add),
                      label: Text('Add expense'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final e = expenses[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    'Qty: ${e.quantityBought} · ${e.pricePaid.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    'Per unit: ${e.pricePerUnit.toStringAsFixed(2)} · ${e.purchaseDate.toDDMMMYYYY()}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () => _showExpenseBottomSheet(e),
                    tooltip: 'Edit',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  MedicinesDetailViewModel createViewModel() {
    return ref.read(medicineDetailVm(widget.medicineId));
  }

  @override
  String screenName() => 'Expenses';
}

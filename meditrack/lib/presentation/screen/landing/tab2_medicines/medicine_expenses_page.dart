import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

import 'add_expense_bottom_sheet.dart';
import 'medicines_view_model.dart';

class MedicineExpensesPage extends ConsumerStatefulWidget {
  final int medicineId;

  const MedicineExpensesPage({super.key, required this.medicineId});

  @override
  ConsumerState<MedicineExpensesPage> createState() =>
      _MedicineExpensesPageState();
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () => _showExpenseBottomSheet(null),
            icon: const Icon(Icons.add_rounded),
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
                  ? Text('Error loading expenses', style: theme.textTheme.bodyMedium)
                  : const CircularProgressIndicator(),
            );
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return _EmptyExpenses(onAdd: () => _showExpenseBottomSheet(null));
          }

          final total = expenses.fold(0.0, (s, e) => s + e.pricePaid);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Total Spent · ${expenses.length} purchase${expenses.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '₹ ${total.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest: ${expenses.first.purchaseDate.toDDMMMYYYY()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Purchase History', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),

              ...expenses.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.shopping_bag_rounded, color: primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.purchaseDate.toDDMMMYYYY(),
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${e.quantityBought} units · ₹${e.pricePerUnit.toStringAsFixed(2)}/unit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹ ${e.pricePaid.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showExpenseBottomSheet(e),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseBottomSheet(null),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Purchase', style: TextStyle(color: Colors.white)),
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

class _EmptyExpenses extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyExpenses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No purchases recorded',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Track your medicine purchases to monitor spending.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Purchase'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

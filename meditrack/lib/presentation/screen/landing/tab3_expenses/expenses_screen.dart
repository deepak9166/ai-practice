import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';

import 'expenses_view_model.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen>
    with AutomaticKeepAliveClientMixin {
  ExpenseFilter _filter = ExpenseFilter.monthly;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = ref.read(expensesVm);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Expenses',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ExpenseFilter.values.map((f) {
                final isSelected = f == _filter;
                final label = switch (f) {
                  ExpenseFilter.monthly => 'Monthly',
                  ExpenseFilter.yearly => 'Yearly',
                  ExpenseFilter.lifetime => 'Lifetime',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: primary.withValues(alpha: 0.15),
                    checkmarkColor: primary,
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? primary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected ? primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: StreamBuilder<List<ExpenseWithMedicineName>>(
              stream: vm.watchExpenses(_filter),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final items = snapshot.data!;
                final total = items.fold(0.0, (s, e) => s + e.expense.pricePaid);

                if (items.isEmpty) {
                  return _EmptyExpenses(filter: _filter);
                }

                // Group by medicine for per-medicine summary
                final medicineMap = <String, double>{};
                for (final item in items) {
                  medicineMap[item.medicineName] =
                      (medicineMap[item.medicineName] ?? 0) + item.expense.pricePaid;
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    // Total summary card
                    _TotalCard(total: total, filter: _filter),
                    const SizedBox(height: 16),

                    // Per-medicine breakdown
                    if (medicineMap.length > 1) ...[
                      Text(
                        'By Medicine',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _MedicineBreakdownCard(medicineMap: medicineMap, total: total),
                      const SizedBox(height: 16),
                    ],

                    // Transaction list
                    Text(
                      'All Transactions',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => _ExpenseItem(item: item)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  final ExpenseFilter filter;
  const _TotalCard({required this.total, required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final label = switch (filter) {
      ExpenseFilter.monthly => 'This Month',
      ExpenseFilter.yearly => 'This Year',
      ExpenseFilter.lifetime => 'All Time',
    };

    return Container(
      width: double.infinity,
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
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Spent · $label',
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
        ],
      ),
    );
  }
}

class _MedicineBreakdownCard extends StatelessWidget {
  final Map<String, double> medicineMap;
  final double total;
  const _MedicineBreakdownCard({required this.medicineMap, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final sorted = medicineMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final pct = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹ ${e.value.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    minHeight: 5,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
                if (i < sorted.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Divider(height: 1),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final ExpenseWithMedicineName item;
  const _ExpenseItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final e = item.expense;

    return Padding(
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
              child: Icon(Icons.receipt_long_rounded, color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicineName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${e.quantityBought} units · ₹${e.pricePerUnit.toStringAsFixed(2)}/unit · ${e.purchaseDate.toDDMMMYYYY()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹ ${e.pricePaid.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  final ExpenseFilter filter;
  const _EmptyExpenses({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (filter) {
      ExpenseFilter.monthly => 'this month',
      ExpenseFilter.yearly => 'this year',
      ExpenseFilter.lifetime => 'yet',
    };
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
                Icons.account_balance_wallet_outlined,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No expenses $label',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add expenses from a medicine\'s detail page.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

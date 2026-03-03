import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';

import '../../../common_model/exercise_model.dart';
import '../../base/base_consumer_state.dart';
import 'home_view_model.dart';
import 'upcoming_exercise_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseConsumerState<HomeScreen, HomeViewModel>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final db = ref.read(databaseProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: primary,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MediTrack',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateTime.now().toWeekday()}, ${DateTime.now().toDDMMMYYYY()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<List<IntakeHistory>>(
                    stream: db.watchAllIntakeHistoriesDesc(),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? [];
                      final takenToday = all.where((h) {
                        return h.status.toLowerCase() == 'taken' &&
                            h.intakeTime.isToday();
                      }).length;
                      final upcomingToday = all.where((h) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final tomorrow = today.add(const Duration(days: 1));
                        return h.status.toLowerCase() == 'upcoming' &&
                            !h.intakeTime.isBefore(today) &&
                            h.intakeTime.isBefore(tomorrow);
                      }).length;

                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_rounded,
                              value: '$takenToday',
                              label: 'Taken Today',
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.schedule_rounded,
                              value: '$upcomingToday',
                              label: 'Upcoming',
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<double>(
                              future: _getMonthlyTotal(db),
                              builder: (context, snap) {
                                final total = snap.data ?? 0.0;
                                return _StatCard(
                                  icon: Icons.account_balance_wallet_rounded,
                                  value: '₹${total.toStringAsFixed(0)}',
                                  label: 'This Month',
                                  color: const Color(0xFFE65100),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Low stock banner
                StreamBuilder<List<Medicine>>(
                  stream: db.watchLowStockMedicines(),
                  builder: (context, snapshot) {
                    final lowStock = snapshot.data ?? [];
                    if (lowStock.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _LowStockBanner(medicines: lowStock),
                    );
                  },
                ),

                // Today's Medicines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Today's Medicines",
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<MedicineModel>>(
                  stream: viewModel.todayMedicinesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final list = snapshot.data!;
                    if (list.isEmpty) {
                      return _EmptyTodayMedicines();
                    }
                    return Column(
                      children: list.map((item) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _TodayMedicineCard(
                          item: item,
                          onMarkTaken: () {
                            if (item.intakeId != null) {
                              _showMarkAsTakenDialog(context, item);
                            }
                          },
                        ),
                      )).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Upcoming medicines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Upcoming Reminders',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: UpcomingMedicineList(
                    stream: viewModel.upcomingMedicinesStream,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _getMonthlyTotal(AppDatabase db) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final expenses = await db.getAllExpenses(from: from, to: to);
    return expenses.fold<double>(0.0, (sum, e) => sum + e.pricePaid);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  void _showMarkAsTakenDialog(BuildContext context, MedicineModel item) {
    final theme = Theme.of(context);
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Mark as Taken',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you take this medicine?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, taken'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && item.intakeId != null) {
        viewModel.markIntakeAsTaken(item.intakeId!);
      }
    });
  }

  @override
  HomeViewModel createViewModel() => ref.read(homeVm);

  @override
  String screenName() => 'Home';

  @override
  bool get wantKeepAlive => true;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final List<Medicine> medicines;
  const _LowStockBanner({required this.medicines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = medicines.take(3).map((m) => m.name).join(', ');
    final extra = medicines.length > 3 ? ' +${medicines.length - 3} more' : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Low stock: $names$extra',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMedicineCard extends StatelessWidget {
  final MedicineModel item;
  final VoidCallback onMarkTaken;
  const _TodayMedicineCard({required this.item, required this.onMarkTaken});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isPending = item.intakeId != null;

    DateTime? intakeTime;
    try {
      intakeTime = DateTime.parse(item.date);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.medication_rounded, color: primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      intakeTime != null ? intakeTime.toTime12Hour() : '--',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.type.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.medication_liquid_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        item.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            GestureDetector(
              onTap: onMarkTaken,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Take',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyTodayMedicines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All done for today!',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'No pending medicines right now.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

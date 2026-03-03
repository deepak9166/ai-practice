import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';

enum HistoryFilter { all, taken, missed, upcoming }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  HistoryFilter _filter = HistoryFilter.all;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final db = ref.read(databaseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('History', style: theme.textTheme.titleLarge),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HistoryFilter.values.map((f) {
                  final isSelected = f == _filter;
                  final label = switch (f) {
                    HistoryFilter.all => 'All',
                    HistoryFilter.taken => 'Taken',
                    HistoryFilter.missed => 'Missed',
                    HistoryFilter.upcoming => 'Upcoming',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: _statusColor(f == HistoryFilter.all ? 'Taken' : label, theme).withValues(alpha: 0.15),
                      checkmarkColor: _statusColor(f == HistoryFilter.all ? 'Taken' : label, theme),
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? _statusColor(f == HistoryFilter.all ? 'Taken' : label, theme)
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? _statusColor(f == HistoryFilter.all ? 'Taken' : label, theme)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<IntakeHistory>>(
              stream: db.watchAllIntakeHistoriesDesc(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final all = snapshot.data!;

                return FutureBuilder<List<Medicine>>(
                  future: db.getAllMedicines(),
                  builder: (context, medSnap) {
                    final medicines = medSnap.data ?? [];
                    final medMap = {for (var m in medicines) m.id: m.name};

                    final filtered = all.where((h) {
                      if (_filter == HistoryFilter.all) return true;
                      final status = h.status.toLowerCase();
                      return switch (_filter) {
                        HistoryFilter.taken => status == 'taken',
                        HistoryFilter.missed => status == 'missed',
                        HistoryFilter.upcoming => status == 'upcoming',
                        HistoryFilter.all => true,
                      };
                    }).toList();

                    if (filtered.isEmpty) {
                      return _EmptyHistory(filter: _filter);
                    }

                    // Stats row
                    final takenCount = all.where((h) => h.status.toLowerCase() == 'taken').length;
                    final missedCount = all.where((h) => h.status.toLowerCase() == 'missed').length;
                    final totalCount = takenCount + missedCount;
                    final adherence = totalCount > 0 ? (takenCount / totalCount * 100).round() : 0;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: [
                        // Adherence card
                        if (_filter == HistoryFilter.all)
                          _AdherenceCard(
                            takenCount: takenCount,
                            missedCount: missedCount,
                            adherence: adherence,
                          ),
                        if (_filter == HistoryFilter.all) const SizedBox(height: 16),

                        Text(
                          '${filtered.length} record${filtered.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...filtered.map((h) => _HistoryItem(
                          intake: h,
                          medicineName: medMap[h.medicineId] ?? 'Unknown',
                        )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    return switch (status.toLowerCase()) {
      'taken' => const Color(0xFF2E7D32),
      'missed' => theme.colorScheme.error,
      'upcoming' => theme.colorScheme.primary,
      _ => theme.colorScheme.primary,
    };
  }
}

class _AdherenceCard extends StatelessWidget {
  final int takenCount;
  final int missedCount;
  final int adherence;
  const _AdherenceCard({
    required this.takenCount,
    required this.missedCount,
    required this.adherence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final takenColor = const Color(0xFF2E7D32);
    final missedColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adherence Overview', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  count: takenCount,
                  label: 'Taken',
                  color: takenColor,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  count: missedCount,
                  label: 'Missed',
                  color: missedColor,
                  icon: Icons.cancel_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  count: adherence,
                  label: 'Rate %',
                  color: primary,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          if (takenCount + missedCount > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: takenCount / (takenCount + missedCount),
                minHeight: 8,
                backgroundColor: missedColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(takenColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  const _StatChip({required this.count, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IntakeHistory intake;
  final String medicineName;
  const _HistoryItem({required this.intake, required this.medicineName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = intake.status;
    final statusColor = switch (status.toLowerCase()) {
      'taken' => const Color(0xFF2E7D32),
      'missed' => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };
    final statusIcon = switch (status.toLowerCase()) {
      'taken' => Icons.check_circle_rounded,
      'missed' => Icons.cancel_rounded,
      _ => Icons.schedule_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    intake.intakeTime.toReadableDateTime(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (intake.doseValue != null)
                    Text(
                      'Dose: ${intake.doseValue!.toStringAsFixed(intake.doseValue! % 1 == 0 ? 0 : 2)} units',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final HistoryFilter filter;
  const _EmptyHistory({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (filter) {
      HistoryFilter.all => 'No history yet',
      HistoryFilter.taken => 'No taken records',
      HistoryFilter.missed => 'No missed records',
      HistoryFilter.upcoming => 'No upcoming reminders',
    };
    final sub = switch (filter) {
      HistoryFilter.all => 'Set medicine reminders to start tracking.',
      HistoryFilter.taken => 'Keep up the good work!',
      HistoryFilter.missed => 'Great — no missed doses!',
      HistoryFilter.upcoming => 'Set reminders from a medicine\'s detail page.',
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
                Icons.history_rounded,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(sub, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

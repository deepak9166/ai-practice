import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import 'package:meditrack/presentation/screen/landing/tab2_medicines/remaning_medicine_counts.dart';

import '../../../common_model/dropdown_value_model.dart';
import '../../../common_widgets/custom_input_dropdown.dart';
import 'medicines_view_model.dart';

class MedicineDetailPage extends ConsumerStatefulWidget {
  final int medicineId;
  const MedicineDetailPage({super.key, required this.medicineId});

  @override
  ConsumerState<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState
    extends BaseConsumerState<MedicineDetailPage, MedicinesDetailViewModel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Medicine Detail', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () => AppRouter.push(
              context,
              AppConstants.routeUpdateMedicine,
              extra: widget.medicineId,
            ),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => AppRouter.push(
              context,
              AppConstants.routeMedicineExpenses,
              extra: widget.medicineId,
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Expenses',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReminderBottomSheet,
        backgroundColor: Colors.black,
        icon: const Icon(CupertinoIcons.alarm_fill, color: Colors.white),
        label: const Text('Set Reminder', style: TextStyle(color: Colors.white)),
        elevation: 4,
      ),
      body: ScreenStateAware(
        state: viewModel.screenState,
        builder: (context) {
          final medicine = viewModel.medicineDetail;
          if (medicine == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Medicine header card
                _MedicineHeaderCard(medicine: medicine),
                const SizedBox(height: 16),

                // Stock card
                RemainingMedicineCounts(medicineId: widget.medicineId),
                const SizedBox(height: 16),

                // Intake history
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reminder Log', style: theme.textTheme.titleSmall),
                    TextButton.icon(
                      onPressed: () => AppRouter.push(
                        context,
                        AppConstants.routeMedicineExpenses,
                        extra: widget.medicineId,
                      ),
                      icon: Icon(Icons.add_circle_outline_rounded, size: 16, color: primary),
                      label: Text('Add Expense', style: TextStyle(color: primary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<IntakeHistory>>(
                  stream: viewModel.fetchLogs(),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return _EmptyLog();
                    }
                    return Column(
                      children: data.map((item) => _IntakeLogItem(item: item)).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  createViewModel() => ref.read(medicineDetailVm(widget.medicineId));

  @override
  String screenName() => 'Medicine Detail';

  void _showReminderBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (contextdd) => ReminderSetupView(
        viewModel: viewModel,
        onUpdate: (selectedDate, repeatedValue, doseValue) {
          viewModel.addReminder(selectedDate, repeatedValue, context, doseValue: doseValue);
        },
      ),
    );
  }
}

class _MedicineHeaderCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineHeaderCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.12), primary.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.medication_rounded, color: primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(
                      label: '${medicine.totalQuantity} units',
                      icon: Icons.inventory_2_outlined,
                      color: primary,
                    ),
                    const SizedBox(width: 8),
                    if (medicine.lowStockAlert)
                      _InfoChip(
                        label: 'Alert ON',
                        icon: Icons.notifications_active_rounded,
                        color: medicine.totalQuantity < 10
                            ? theme.colorScheme.error
                            : const Color(0xFF2E7D32),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntakeLogItem extends StatelessWidget {
  final IntakeHistory item;
  const _IntakeLogItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.status;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.intakeTime.toReadableDateTime(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (item.doseValue != null)
                    Text(
                      'Dose: ${item.doseValue!.toStringAsFixed(item.doseValue! % 1 == 0 ? 0 : 2)} units',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

class _EmptyLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm_add_rounded, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'No reminders set yet.\nTap the button below to add one.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reminder Setup Bottom Sheet ────────────────────────────────────────────

class ReminderSetupView extends StatefulWidget {
  final MedicinesDetailViewModel viewModel;
  final void Function(DateTime selectedDate, int repeatedValue, double? doseValue) onUpdate;
  const ReminderSetupView({super.key, required this.viewModel, required this.onUpdate});

  @override
  State<ReminderSetupView> createState() => _ReminderSetupViewState();
}

class _ReminderSetupViewState extends State<ReminderSetupView> {
  DateTime selectedDate = DateTime.now();
  DropdownValueModel? selectedValue;
  DropdownValueModel<double>? selectedDose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(CupertinoIcons.alarm_fill, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Set Reminder',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                showTimeSeparator: true,
                initialDateTime: DateTime.now(),
                use24hFormat: false,
                onDateTimeChanged: (DateTime value) {
                  selectedDate = value;
                },
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<DropdownValueModel<double>>>(
              future: widget.viewModel.fetchDose(),
              builder: (context, snapshot) {
                final doseItems = snapshot.data ?? [];
                return CustomDropdownInput<DropdownValueModel<double>>(
                  label: 'Dose',
                  hint: 'Select dose amount',
                  items: doseItems,
                  onChanged: (value) => setState(() => selectedDose = value),
                  value: selectedDose,
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: widget.viewModel.fetchRepeat(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                return CustomDropdownInput<DropdownValueModel>(
                  label: 'Repeat',
                  hint: 'Select repeat frequency',
                  items: data,
                  onChanged: (value) => setState(() => selectedValue = value),
                  value: selectedValue,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    borderColor: theme.primaryColor,
                    textColor: theme.primaryColor,
                    onPressed: () {
                      widget.viewModel.selectedValue = null;
                      context.hideKeyboard();
                      AppRouter.pop(context);
                    },
                    text: 'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      if (selectedValue?.value == null) {
                        context.showWarning('Please select a repeat option');
                        return;
                      }
                      final dose = selectedDose?.value;
                      widget.onUpdate(selectedDate, selectedValue!.value as int, dose);
                      context.hideKeyboard();
                      AppRouter.pop(context);
                    },
                    text: 'Set Reminder',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
import '../../../common_widgets/spacing_widgets.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actions: [
          IconButton(
            onPressed: () {
              AppRouter.push(
                context,
                AppConstants.routeUpdateMedicine,
                extra: widget.medicineId,
              );
            },
            icon: Icon(Icons.edit),
            tooltip: 'Update',
          ),
          IconButton(
            onPressed: () {
              AppRouter.push(
                context,
                AppConstants.routeMedicineExpenses,
                extra: widget.medicineId,
              );
            },
            icon: Icon(Icons.add),
            tooltip: 'Expenses',
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: viewModel.isSetReminder,
        builder: (context, value, child) {
          return FloatingActionButton(
            tooltip: "Set Alarm",
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () => _showReminderBottomSheet(),
            backgroundColor: Colors.black,
            child: Icon(CupertinoIcons.alarm_fill, color: Colors.white),
          );
        },
      ),
      body: ScreenStateAware(
        state: viewModel.screenState,
        builder: (context) => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Medicine : ${viewModel.medicineDetail?.name}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              VerticalSpacing.medium,

              RemainingMedicineCounts(medicineId: widget.medicineId),
              Divider(),
              Text(
                "Alarms Logs:",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              VerticalSpacing.small,
              StreamBuilder<List<IntakeHistory>>(
                stream: viewModel.fetchLogs(),
                builder: (context, snapshot) {
                  var data = snapshot.data ?? [];
                  return Column(
                    children: data
                        .map(
                          (item) => ListTile(
                            dense: true,
                            title: Text(item.intakeTime.toReadableDateTime()),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  createViewModel() {
    return ref.read(medicineDetailVm(widget.medicineId));
  }

  @override
  String screenName() {
    return "Medicine Detail";
  }

  void _showReminderBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (contextdd) {
        return ReminderSetupView(
          viewModel: viewModel,
          onUpdate: (selectedDate, repeatedValue, doseValue) {
            viewModel.addReminder(
              selectedDate,
              repeatedValue,
              context,
              doseValue: doseValue,
            );
          },
        );
      },
    );
  }
}

class ReminderSetupView extends StatefulWidget {
  final MedicinesDetailViewModel viewModel;
  final void Function(
    DateTime selectedDate,
    int repeatedValue,
    double? doseValue,
  )
  onUpdate;
  const ReminderSetupView({
    super.key,
    required this.viewModel,
    required this.onUpdate,
  });

  @override
  State<ReminderSetupView> createState() => _ReminderSetupViewState();
}

class _ReminderSetupViewState extends State<ReminderSetupView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text('Set Reminder', style: TextTheme.of(context).titleMedium),
                // VerticalSpacing.medium,
                SizedBox(
                  height: 240,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    showTimeSeparator: true,
                    initialDateTime: DateTime.now(),
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime value) {
                      selectedDate = value;
                    },
                  ),
                ),
                VerticalSpacing.small,
                FutureBuilder<List<DropdownValueModel<double>>>(
                  future: widget.viewModel.fetchDose(),
                  builder: (context, snapshot) {
                    var doseItems = snapshot.data ?? [];
                    return CustomDropdownInput<DropdownValueModel<double>>(
                      label: "Dose",
                      hint: "Select dose",
                      items: doseItems,
                      onChanged: (value) {
                        setState(() => selectedDose = value);
                      },
                      value: selectedDose,
                    );
                  },
                ),
                VerticalSpacing.small,
                FutureBuilder(
                  future: widget.viewModel.fetchRepeat(),
                  builder: (context, snapshot) {
                    var data = snapshot.data ?? [];
                    return SizedBox(
                      child: CustomDropdownInput<DropdownValueModel>(
                        label: "Repeat",
                        hint: "Select Repeat Reminder",
                        items: data,
                        onChanged: (value) {
                          setState(() => selectedValue = value);
                        },
                        value: selectedValue,
                      ),
                    );
                  },
                ),
                VerticalSpacing.medium,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        borderColor: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          widget.viewModel.selectedValue = null;
                          context.hideKeyboard();
                          AppRouter.pop(context);
                        },
                        text: 'Cancel',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          if (selectedValue?.value == null) {
                            context.showWarning('Select Reminder');
                            return;
                          }
                          final dose = selectedDose?.value;
                          widget.onUpdate(
                            selectedDate,
                            selectedValue!.value as int,
                            dose,
                          );
                          context.hideKeyboard();
                          AppRouter.pop(context);
                        },
                        text: 'DONE',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now();
  DropdownValueModel? selectedValue;
  DropdownValueModel<double>? selectedDose;
}

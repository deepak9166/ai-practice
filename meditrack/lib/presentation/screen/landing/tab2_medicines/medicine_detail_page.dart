import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';

import '../../../../config/svg_config.dart';
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
      appBar: AppBar(title: Text('Detail')),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: viewModel.isSetReminder,
        builder: (context, value, child) {
          return FloatingActionButton(
            onPressed: () {
              _showReminderBottomSheet();
            },
            child: SmartImageView(SvgImageId.clockIcon.path),
          );
        },
      ),
      body: ScreenStateAware(
        state: viewModel.screenState,
        builder: (context) => Column(
          children: [
            Text("Medicine : ${viewModel.medicineDetail?.name}"),

            VerticalSpacing.medium,
            // Row(children: [CustomCheckboxList(data: checkValues)]),
            VerticalSpacing.medium,
            Divider(),
            Text("Logs:"),
            StreamBuilder(
              stream: viewModel.fetchLogs(),
              builder: (context, snapshot) {
                var data = snapshot.data ?? [];
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item = data[index];
                    return ListTile(
                      title: Text(item.intakeTime.toIso8601String()),
                    );
                  },
                );
              },
            ),
          ],
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
      builder: (contextdd) {
        return ReminderSetupView(
          viewModel: viewModel,
          onUpdate: (selectedDate, repeatedValue) {
            // appLog('Selected value ${selectedDate}. ${repeatedValue}');
            viewModel.addReminder(selectedDate, repeatedValue, context);
          },
        );
      },
    );
  }
}

class ReminderSetupView extends StatefulWidget {
  final MedicinesDetailViewModel viewModel;
  final Function(DateTime selectedDate, int repeatedValue) onUpdate;
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

                // VerticalSpacing.medium,
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
                          selectedValue = value;
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
                          AppRouter.pop(context);
                        },
                        text: 'Cancel',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          widget.onUpdate(selectedDate, selectedValue?.value);
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
}

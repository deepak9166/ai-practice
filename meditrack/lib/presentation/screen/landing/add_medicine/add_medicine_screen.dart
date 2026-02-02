import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

import '../../../../config/svg_config.dart';
import '../../../../core/utils/image_picker_utils.dart';
import '../../../../extension/sage_execute_extesion.dart';
import '../../../../log/app_logs.dart';
import '../../../common_model/action_button.dart';
import '../../../common_model/checkbox_value_model.dart';
import '../../../common_model/dropdown_value_model.dart';
import '../../../common_widgets/custom_button.dart';
import '../../../common_widgets/custom_checkbox_list.dart';
import '../../../common_widgets/custom_input_dropdown.dart';
import '../../../common_widgets/custom_input_field.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../common_widgets/user_image_upload_bottom_sheet.dart';
import '../../../common_widgets/visual_profress_viewer.dart';
import '../../base/screen_state.dart';
import '../../base/screen_state_aware.dart';
import 'add_medicine_view_model.dart';

// These cover 90% of real usage:
// Tablet
// Capsule
// Syrup
// Injection
// Drops (eye / ear / nasal)
// Cream / Ointment

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState
    extends BaseConsumerState<AddMedicineScreen, AddMedicineViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _selectedImage = ValueNotifier('');

  List<DropdownValueModel> dropdownListMedicineType = [
    DropdownValueModel(title: 'Tablet', value: '1'),
    DropdownValueModel(title: 'Capsule', value: '2'),
    DropdownValueModel(title: 'Syrup', value: '3'),
    DropdownValueModel(title: 'Injection', value: '4'),
    DropdownValueModel(title: 'Drops (eye / ear / nasal)', value: '5'),
    DropdownValueModel(title: 'Total Reps Per Muscle Group', value: '6'),
    DropdownValueModel(title: 'Cream / Ointment', value: '7'),
  ];

  List<DropdownValueModel> doseOfMedicine = [
    DropdownValueModel(title: '1/4', value: '1'),
    DropdownValueModel(title: '1/3', value: '2'),
    DropdownValueModel(title: '1/2', value: '3'),
    DropdownValueModel(title: '1', value: '4'),
    DropdownValueModel(title: '2', value: '5'),
    DropdownValueModel(title: '3', value: '6'),
    DropdownValueModel(title: '4', value: '7'),
  ];

  List<DropdownValueModel> dropdownListReepeat = [
    DropdownValueModel(title: 'Never', value: '1'),
    DropdownValueModel(title: 'Every Day', value: '2'),
    DropdownValueModel(title: 'Monday to Friday', value: '3'),
    DropdownValueModel(title: 'Every Week', value: '4'),
    DropdownValueModel(title: 'Every Month', value: '5'),
    DropdownValueModel(title: 'Every Year', value: '6'),
  ];

  List<CheckBoxValueModel> checkValues = [
    CheckBoxValueModel(title: 'Morning', value: false),
    CheckBoxValueModel(title: 'Afternoon', value: false),
    CheckBoxValueModel(title: 'Evening', value: false)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medicine'),
        actions: [
          ActionButtonAppBar(
            title: 'Finish',
            onPressed: () {
              appLog('finish tapped');
            },
          ),
          SizedBox(width: 20),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInputField(
                    controller: viewModel.medicineNameTextC,
                    hint: 'Enter medicine name',
                  ),
                  VerticalSpacing.medium,
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownInput(
                          hint: "Dose",
                          items: doseOfMedicine,
                          onChanged: (value) {},
                          value: null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomDropdownInput(
                          hint: "Type",
                          items: dropdownListMedicineType,
                          onChanged: (value) {},
                          value: null,
                        ),
                      ),
                    ],
                  ),

                  VerticalSpacing.medium,

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder(
                      valueListenable: viewModel.isSetReminder,
                      builder: (context, value, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              radius: 8,
                              onTap: () {
                                viewModel.isSetReminder.value =
                                    !viewModel.isSetReminder.value;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryFixed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SmartImageView(SvgImageId.clockIcon.path),
                                      SizedBox(width: 8),
                                      Text(
                                        !value ? "Remove" : 'Set Reminder',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (value == false)
                              Column(
                                children: [
                                  VerticalSpacing.medium,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                            if (picked != null) {
                                              viewModel.startDateTextC.text =
                                                  '${picked.day}-${picked.month}-${picked.year}';
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFD0C9EA,
                                              ).withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    viewModel
                                                            .startDateTextC
                                                            .text
                                                            .isNotEmpty
                                                        ? viewModel
                                                              .startDateTextC
                                                              .text
                                                        : 'Select Date',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                                SvgPicture.asset(
                                                  SvgImageId.calendar.path,
                                                  width: 24,
                                                  height: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                            if (picked != null) {
                                              viewModel.timeTextC.text = picked
                                                  .format(context);
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFD0C9EA,
                                              ).withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    viewModel
                                                            .timeTextC
                                                            .text
                                                            .isNotEmpty
                                                        ? viewModel
                                                              .timeTextC
                                                              .text
                                                        : 'Select Time',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                                SvgPicture.asset(
                                                  SvgImageId.clock.path,
                                                  width: 24,
                                                  height: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  VerticalSpacing.medium,
                                  Row(
                                    children: [
                                      Text(
                                        'Repeat',
                                        style: TextTheme.of(
                                          context,
                                        ).titleMedium,
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: 200,
                                        child: CustomDropdownInput(
                                          hint: "Never",
                                          items: dropdownListReepeat,
                                          onChanged: (value) {
                                            viewModel.frequencyTextC.text =
                                                value?.value ?? '';
                                          },
                                          value: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  VerticalSpacing.medium,
                  Row(children: [CustomCheckboxList(data: checkValues)]),
                  VerticalSpacing.medium,

                  VisualProgressViewer(
                    height: 80,
                    title: 'Select Medicine Image (Optional)',
                    subtitle: '',
                    placeHolder: 'Upload image (Optional)',
                    imageNotifier: _selectedImage,
                    onPickImage: () => _pickImage(),
                    onRemove: () {
                      appLog('removed images');
                      _selectedImage.value = "";
                    },
                  ),
                  VerticalSpacing.large,
                  ScreenStateAware(
                    showApiProgressInPlace: true,
                    state: viewModel.screenState,
                    builder: (context) => CustomButton(
                      onPressed: () {
                        ref.safeExecute(
                          key: "save_workout",
                          action: () => viewModel.saveMedicine(context),
                        );
                      },
                      text: 'ADD MEDICINE',
                      backgroundColor: Colors.black,
                      isLoading:
                          viewModel.screenState.value ==
                          ScreenState.apiProgress,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    // final XFile? image = await pickImage(context);
    // if (image != null) {
    // _selectedImage.value = image;
    // }

    showModalBottomSheet(
      context: context,
      builder: (context) => UserImageUploadBottomSheet(
        onUpload: (imageUrl, _) {
          appLog('Image URL: $imageUrl, MSG Level: ');
          _selectedImage.value = imageUrl;
        },
      ),
    );
  }

  @override
  void dispose() {
    _selectedImage.dispose();
    super.dispose();
  }

  @override
  AddMedicineViewModel createViewModel() {
    return ref.read(addMedicineVm);
  }

  @override
  String screenName() {
    return "Add Medicines";
  }
}

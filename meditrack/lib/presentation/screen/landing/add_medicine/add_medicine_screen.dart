import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

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
import '../../../common_widgets/custom_textfield_autofill.dart';
import '../../../common_widgets/custom_textfield_dropdown.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../common_widgets/user_image_upload_bottom_sheet.dart';
import '../../../common_widgets/visual_profress_viewer.dart';
import '../../base/screen_state.dart';
import '../../base/screen_state_aware.dart';
import '../../med_calculator/med_calculator.dart';
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

  List<DropdownValueModel<double>> doseOfMedicine = [
    DropdownValueModel(title: '1/4', value: 0.25),
    DropdownValueModel(title: '1/3', value: 0.75),
    DropdownValueModel(title: '1/2', value: 0.50),
    DropdownValueModel(title: '1', value: 1.0),
    DropdownValueModel(title: '2', value: 2.0),
    DropdownValueModel(title: '3', value: 3.0),
    DropdownValueModel(title: '4', value: 4.0),
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
    CheckBoxValueModel(title: 'Low stock alert', value: true),
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
                  CustomTextfieldAutofill(
                    hintText: 'Enter Medicine name',
                    fetchSuggestions: (query) => viewModel.fetchMedicines(query),
                    controller: viewModel.medicineNameTextC,
                    onItemSelected: (value) {
                    appLog('value ${value}');
                    },
                  ),

                  VerticalSpacing.medium,
                  FutureBuilder(
                    future: viewModel.getAllMedicinesType(),
                    builder: (context, asyncSnapshot) {
                      return CustomDropdownInput<DropdownValueModel>(
                        hint: "Type",
                        items: asyncSnapshot.data ?? [],
                        onChanged: (value) {
                          appLog('type...');

                          viewModel.typeTextC = (value?.value ?? 0);
                        },
                        value: null,
                      );
                    },
                  ),

                  VerticalSpacing.medium,
                  Row(
                    children: [
                      Expanded(
                        child: CustomInputField(
                          hint: "Total quantity",
                          controller: viewModel.totalQuantity,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showMedicineCalculator();
                        },
                        icon: Icon(Icons.calculate),
                      ),
                    ],
                  ),

                  CustomCheckboxList(
                    data: checkValues,
                    showOptionRow: true,
                    onChanged: (value) {
                      viewModel.isLowAlert = value.value;
                    },
                  ),

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

  void _showMedicineCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),

        content: MedCalculator(
          onDone: (totalMedicne) {
            viewModel.totalQuantity.text = totalMedicne;
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

import '../../../../core/utils/image_picker_utils.dart';
import '../../../../extension/sage_execute_extesion.dart';
import '../../../../log/app_logs.dart';
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
import '../../med_calculator/med_calculator.dart';
import 'update_medicine_view_model.dart';

class UpdateMedicineScreen extends ConsumerStatefulWidget {
  final int medicineId;

  const UpdateMedicineScreen({super.key, required this.medicineId});

  @override
  ConsumerState<UpdateMedicineScreen> createState() =>
      _UpdateMedicineScreenState();
}

class _UpdateMedicineScreenState
    extends BaseConsumerState<UpdateMedicineScreen, UpdateMedicineViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _selectedImage = ValueNotifier('');

  List<CheckBoxValueModel> get checkValues => [
        CheckBoxValueModel(title: 'Low stock alert', value: viewModel.isLowAlert),
      ];

  @override
  void onModelReady(UpdateMedicineViewModel model) {
    super.onModelReady(model);
    model.loadMedicine().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Medicine')),
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
                    hint: 'Medicine name',
                    controller: viewModel.medicineNameTextC,
                  ),
                  VerticalSpacing.medium,
                  FutureBuilder<List<DropdownValueModel<int>>>(
                    future: viewModel
                        .getAllMedicinesType()
                        .then((list) => list.cast<DropdownValueModel<int>>()),
                    builder: (context, asyncSnapshot) {
                      return CustomDropdownInput<DropdownValueModel<int>>(
                        hint: "Type",
                        items: asyncSnapshot.data ?? [],
                        value: viewModel.selectedType,
                        onChanged: (value) {
                          viewModel.typeTextC = value?.value;
                          viewModel.selectedType = value;
                          setState(() {});
                        },
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
                        onPressed: _showMedicineCalculator,
                        icon: Icon(Icons.calculate),
                      ),
                    ],
                  ),
                  CustomCheckboxList(
                    data: checkValues,
                    showOptionRow: true,
                    onChanged: (value) {
                      viewModel.isLowAlert = value.value;
                      setState(() {});
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
                          key: "update_medicine",
                          action: () => viewModel.saveMedicine(context),
                        );
                      },
                      text: 'UPDATE MEDICINE',
                      backgroundColor: Colors.black,
                      isLoading:
                          viewModel.screenState.value == ScreenState.apiProgress,
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
          appLog('Image URL: $imageUrl');
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
  UpdateMedicineViewModel createViewModel() {
    return ref.read(updateMedicineVm(widget.medicineId));
  }

  @override
  String screenName() => "Update Medicine";

  void _showMedicineCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        content: MedCalculator(
          onDone: (totalMedicine) {
            viewModel.totalQuantity.text = totalMedicine;
          },
        ),
      ),
    );
  }
}

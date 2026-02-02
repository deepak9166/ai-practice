import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/enum/filter_enum.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/presentation/common_widgets/custom_selection_field.dart';
import 'package:meditrack/presentation/common_widgets/user_image_upload_bottom_sheet.dart';
import 'package:meditrack/presentation/common_widgets/visual_progress_picker.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/template_type_filter.dart';
import 'package:meditrack/presentation/screens/custom_exercise/custom_widget/equipment_popup_content.dart';
import 'package:meditrack/presentation/screens/custom_exercise/custom_widget/selected_chip_widget.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state_aware.dart';
import 'package:meditrack/presentation/screens/custom_exercise/custom_widget/time_based_exercise_widget.dart';
import 'package:meditrack/presentation/screens/custom_exercise/view_model/custom_exercise_view_model.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/muscle_chip_widget.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../../log/app_logs.dart';
import '../../common_widgets/visual_profress_viewer.dart';

class AddCustomExercise extends ConsumerStatefulWidget {
  const AddCustomExercise({super.key});

  @override
  ConsumerState<AddCustomExercise> createState() => _AddCustomExerciseState();
}

class _AddCustomExerciseState
    extends BaseConsumerState<AddCustomExercise, TemplatesViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _exerciseIntensityController = TextEditingController();
  final _weightProxyController = TextEditingController();
  final _repsProxyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _msgController = TextEditingController();
  final _templateTypeController = TextEditingController();
  List<String> selectedPrimaryMuscles = [
    'Upper Chest',
    'Middle Chest',
    'Lower Chest',
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplateData();
  }

  void _loadTemplateData() {
    // Load existing template data - for now, dummy data
    _exerciseNameController.text = 'Strenght';
    _exerciseIntensityController.text = '75';
    _weightProxyController.text = '50';
    _repsProxyController.text = '10';
    _descriptionController.text = 'This is a description';
    _msgController.text = 'Middle Chest, Lower Chest';
    _templateTypeController.text = 'Bodyweight-only / Calisthenics';
  }

  void _removeExercise(int index) {
    final exercises = List<Exercise>.from(viewModel.listExercises.value);
    exercises.removeAt(index);
    viewModel.listExercises.value = exercises;
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _exerciseIntensityController.dispose();
    _weightProxyController.dispose();
    _repsProxyController.dispose();
    _descriptionController.dispose();
    _msgController.dispose();
    _templateTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var filterViewModel = ref.read(filterVm([FilterTypes.templateType]));
    final viewModel = ref.watch(customExerciseViewModel);
    return Scaffold(
      // appBar: CustomAppBar(title: 'Add Exercises'),
      appBar:  AppBar(title: Text('Add Exercises')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomInputField(
                        controller: _exerciseNameController,
                        label: 'Exercise Name',
                        hint: 'Enter Exercise Name',
                        tooltip: 'Enter Exercise Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Exercise Name';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Total number of muscles',
                        placeholder: 'Select Muscles',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        onTap: (position) {},
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Primary Muscle Group',
                        placeholder: 'Select Primary Muscle Group',
                        tooltip: 'Primary Muscle Group',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        selectedWidget: selectedPrimaryMuscles.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedPrimaryMuscles
                                    .map(
                                      (title) => SelectedChipWidget(
                                        title: title,
                                        onRemove: () {},
                                      ),
                                    )
                                    .toList(),
                              )
                            : null,
                        onTap: (position) {},
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Secondary Muscle Group',
                        placeholder: 'Select Secondary Muscle Group',
                        tooltip: 'Secondary Muscle Group',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        selectedWidget: selectedPrimaryMuscles.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedPrimaryMuscles
                                    .map(
                                      (title) => SelectedChipWidget(
                                        title: title,
                                        onRemove: () {},
                                      ),
                                    )
                                    .toList(),
                              )
                            : null,
                        onTap: (position) {},
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Template Type',
                        placeholder: 'Select Template Type',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        onTap: (position) {
                          showModalBottomSheet(
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            isScrollControlled: true,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * .78,
                            ),
                            context: context,
                            builder: (context) => TemplateTypeFilter(
                              templateTypeList:
                                  filterViewModel.templateTypeList,
                              heading: "",
                            ),
                          );
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'MMG',
                        placeholder: 'Select MMG Level',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        onTap: (position) {},
                        selectedWidget: selectedPrimaryMuscles.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedPrimaryMuscles
                                    .map(
                                      (title) =>
                                          SelectedChipWidget(title: title),
                                    )
                                    .toList(),
                              )
                            : null,
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'MSG',
                        placeholder: 'Select MSG Level',
                        trailingIcon: SmartImageView(
                          SvgImageId.arrowSquareDown.path,
                        ),
                        onTap: (position) {
                          context.push(AppConstants.routeSelectMsgLevel);
                        },
                      ),
                      VerticalSpacing.medium,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MuscleChipWidget(
                            title: 'Upper Chest',
                            value: '0.75',
                            onRemove: () {},
                          ),
                          MuscleChipWidget(
                            title: 'Middle Chest',
                            value: '0.75',
                            onRemove: () {},
                          ),
                          MuscleChipWidget(
                            title: 'Lower Chest',
                            value: '0.75',
                            onRemove: () {},
                          ),
                        ],
                      ),

                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _exerciseIntensityController,
                        label: 'Exercise Intensity for TV Calc.',
                        hint: 'Enter Exercise Intensity (in %)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Exercise Intensity for TV Calc';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Body Weight-based Exercise',
                        placeholder: 'Select Body Weight-based Exercise',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconDownArrow.path,
                        ),
                        onTap: (position) {},
                      ),
                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _weightProxyController,
                        label: 'Weight Proxy for BW Exercise (as % of BW).',
                        hint: 'Enter Weight Proxy (in %)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Weight Proxy for BW Exercise (as % of BW).';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isTimeBased,
                        builder: (context, isTimeBased, _) {
                          return TimeBasedExerciseWidget(
                            isTimeBased: isTimeBased,
                            onChanged: (value) {
                              viewModel.isTimeBased.value = value;
                            },
                          );
                        },
                      ),

                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _repsProxyController,
                        label: 'Reps Proxy (every 60 Seconds = x # of Reps)',
                        hint: 'Enter Reps Proxy',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Reps Proxy';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomSelectionField(
                        label: 'Equipments',
                        placeholder: 'Select equipment',
                        tooltip: 'Select equipment',
                        trailingIcon: SmartImageView(
                          SvgImageId.iconUpArrow.path,
                        ),
                        onTap: (position) {
                          showEquipmentPopupMenu(
                            context: context,
                            position: position,
                            viewModel: viewModel,
                          );
                        },
                      ),
                      VerticalSpacing.medium,
                      VisualProgressViewer(
                        subtitle: 'Image',
                        toolTip: 'Select Image',
                        placeHolder: 'Upload image(JPG/PNG)',
                        imageNotifier: viewModel.selectedImage,
                        onPickImage: () => _pickImage(viewModel),
                        onRemove: () {
                          
                        },
                      ),
                      VerticalSpacing.medium,
                      VisualProgressViewer(
                        subtitle: 'Video',
                        toolTip: 'Select Video',
                        placeHolder: 'Upload Video(MP4 upto 60 secs)',
                        imageNotifier: viewModel.selectedVideo,
                        onPickImage: () => _pickVideo(
                          viewModel,
                          maxDuration: Duration(minutes: 1),
                        ),
                        onRemove: () {
                          
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter a Description',
                        tooltip: 'Description',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16.0),
              child: ScreenStateAware(
                showApiProgressInPlace: true,
                state: viewModel.screenState,
                builder: (context) {
                  return CustomButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      viewModel.addExercise();
                      AppRouter.pushReplacement(
                        context,
                        AppConstants.routeACustomExerciseWaitingApprovalScreen,
                      );
                    },
                    text: 'SUBMIT',
                    isLoading:
                        viewModel.screenState.value == ScreenState.apiProgress,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(CustomExerciseViewModel vm) async {
    // final XFile? image = await pickImage(context);
    // if (image != null) {
    //   vm.selectedImage.value = image;
    // }

    showModalBottomSheet(
      context: context,
      builder: (context) => UserImageUploadBottomSheet(
        onUpload: (imageUrl, msgLevel) {
          appLog('Image URL: $imageUrl, MSG Level: $msgLevel');
          vm.selectedImage.value = imageUrl;
        },
      ),
    );
  }

  Future<void> _pickVideo(
    CustomExerciseViewModel vm, {
    Duration? maxDuration,
  }) async {
    final XFile? video = await pickVideo(context, maxDuration: maxDuration);
    if (video != null) {
      vm.selectedVideo.value = video.path;
    }
    // showModalBottomSheet(
    //   context: context,
    //   builder: (context) => UserImageUploadBottomSheet(
    //     onUpload: (imageUrl, msgLevel) {
    //       appLog('Image URL: $imageUrl, MSG Level: $msgLevel');
    //       vm.selectedVideo.value = imageUrl;
    //     },
    //   ),
    // );
  }

  void showEquipmentPopupMenu({
    required BuildContext context,
    required Offset position,
    required CustomExerciseViewModel viewModel,
  }) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: EquipmentPopupContent(viewModel: viewModel),
        ),
      ],
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Edit Template Screen";
  }
}

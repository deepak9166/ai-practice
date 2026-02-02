import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/presentation/common_widgets/custom_selection_field.dart';
import 'package:meditrack/presentation/common_widgets/custom_template_popup_menu.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state_aware.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/mmg_msg_equpment_filter.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/template_type_filter.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/edit_image_card_widget.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/muscle_chip_widget.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/template_exercise_item.dart';
import 'package:meditrack/presentation/screens/templates/exercise_list_screen.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

import '../../../enum/filter_enum.dart';

/// Edit Template Screen
///
/// Screen for editing a selected workout template.
class EditTemplateScreen extends ConsumerStatefulWidget {
  const EditTemplateScreen({super.key});

  @override
  ConsumerState<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState
    extends BaseConsumerState<EditTemplateScreen, TemplatesViewModel> {
  final _formKey = GlobalKey<FormState>();
  final _workoutTypeController = TextEditingController();
  final _msgController = TextEditingController();
  final _templateTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTemplateData();
  }

  void _loadTemplateData() {
    // Load existing template data - for now, dummy data
    _workoutTypeController.text = 'Strenght';
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
    _workoutTypeController.dispose();
    _msgController.dispose();
    _templateTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var filterViewModel = ref.read(filterVm([FilterTypes.templateType]));
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Template',
        actions: [
          CustomTemplatePopupMenu(
            options: const [
              {'value': 'share_template', 'text': 'Share Template'},
            ],
            onSelected: (value) {
              // Handle menu item selection
              switch (value) {
                case 'share_template':
                  appLog('share templates');
                  context.push(AppConstants.routeShareTemplates);
                  break;
              }
            },
          ),
        ],
      ),
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
                      EditImageCardWidget(
                        imageUrl: PngImageId.yoga.path,
                        title: 'Arm circles',
                        onEditTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent, // important
                            builder: (context) {
                              return ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.white,
                                  child: const ExerciseListScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _workoutTypeController,
                        label: 'Workout Type',
                        hint: 'Enter workout type',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Workout Type';
                          }
                          return null;
                        },
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
                        onTap: (position) async {
                          await filterViewModel.getMmgLevel(FilterTypes.mmg);
                          showModalBottomSheet(
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            isScrollControlled: true,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height - 112,
                            ),
                            context: context,
                            builder: (context) => MmgFilter(
                              heading: 'MMG',
                              mmgList: filterViewModel.mmgLevelList,
                            ),
                          );
                        },
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
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<List<Exercise>>(
                        valueListenable: viewModel.listExercises,
                        builder: (context, exercises, child) {
                          return Column(
                            children: exercises.asMap().entries.map((entry) {
                              final index = entry.key;
                              final exercise = entry.value;
                              final exerciseViewModel =
                                  TemplateExerciseViewModel(exercise);
                              return TemplateExerciseItem(
                                viewModel: exerciseViewModel,
                                onRemove: () => _removeExercise(index),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10.0, left: 16, right: 16),
              child: ScreenStateAware(
                showApiProgressInPlace: true,
                state: viewModel.screenState,
                builder: (context) => CustomButton(
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.black,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    // TODO: Implement save template logic
                    context.pop();
                  },
                  text: 'SAVE TEMPLATES',
                  isLoading:
                      viewModel.screenState.value == ScreenState.apiProgress,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ScreenStateAware(
                showApiProgressInPlace: true,
                state: viewModel.screenState,
                builder: (context) => CustomButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    // TODO: Implement save template logic
                    context.pop();
                  },
                  text: 'ADD EXERCISE',
                  isLoading:
                      viewModel.screenState.value == ScreenState.apiProgress,
                ),
              ),
            ),
          ],
        ),
      ),
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

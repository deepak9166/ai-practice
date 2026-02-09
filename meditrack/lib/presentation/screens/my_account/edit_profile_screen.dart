import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/language_keys.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_model/dropdown_value_model.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_dropdown.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'view_model/my_account_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState
    extends BaseConsumerState<EditProfileScreen, MyAccountViewModel> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _ageTooltipController = SuperTooltipController();
  final _dobTooltipController = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    // TODO: Load existing profile data
    _loadProfileData();
  }

  void _loadProfileData() {
    // For now, set dummy data
    _firstNameController.text = 'Debra';
    _lastNameController.text = 'Halt';
    _zipCodeController.text = '332544';
    viewModel.loadProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(myAccountViewModel);
        return Scaffold(
          appBar: CustomAppBar(title: 'Edit Profile'),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomInputField(
                            controller: _firstNameController,
                            label: LanguageKeys.firstName.tr(),
                            hint: LanguageKeys.firstName.tr(),
                            tooltip: 'Enter your first name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter first name';
                              }
                              return null;
                            },
                          ),
                          VerticalSpacing.medium,
                          CustomInputField(
                            controller: _lastNameController,
                            label: LanguageKeys.lastName.tr(),
                            hint: LanguageKeys.lastName.tr(),
                            tooltip: 'Enter your last name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter last name';
                              }
                              return null;
                            },
                          ),
                          VerticalSpacing.medium,
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    viewModel.selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                viewModel.updateSelectedDate(picked);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VerticalSpacing.smallXs,
                                Row(
                                  children: [
                                    Text(
                                      LanguageKeys.DOB.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondaryFixedVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    SuperTooltip(
                                      content: const Text(
                                        'Select your date of birth',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      popupDirection: TooltipDirection.right,
                                      backgroundColor: Colors.black,
                                      barrierColor: Colors.transparent,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      controller: _dobTooltipController,
                                      child: SmartImageView(
                                        SvgImageId.info.path,
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalSpacing.small,
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD0C9EA).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AnimatedBuilder(
                                          animation: viewModel,
                                          builder: (context, _) => Text(
                                            viewModel.selectedDate != null
                                                ? '${viewModel.selectedDate!.day}-${viewModel.selectedDate!.month}-${viewModel.selectedDate!.year}'
                                                : 'Select Date of Birth',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ),
                                      SmartImageView(SvgImageId.calendar.path),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerticalSpacing.medium,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VerticalSpacing.smallXs,
                              Row(
                                children: [
                                  Text(
                                    LanguageKeys.age.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryFixedVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  SuperTooltip(
                                    content: const Text(
                                      'Select your age using the slider',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    popupDirection: TooltipDirection.right,
                                    backgroundColor: Colors.black,
                                    barrierColor: Colors.transparent,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    controller: _ageTooltipController,
                                    child: SmartImageView(SvgImageId.info.path),
                                  ),
                                ],
                              ),
                              VerticalSpacing.small,
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  overlayColor: Colors.white.withOpacity(0.2),
                                  thumbColor: Colors.white,
                                  activeTrackColor: Color(0xFF575757),
                                  inactiveTrackColor: Colors.grey.shade200,
                                ),
                                child: Slider(
                                  value: viewModel.age,
                                  min: 1,
                                  max: 100,
                                  divisions: 99,
                                  label: '${viewModel.age.round()} years old',
                                  onChanged: (value) {
                                    viewModel.updateAge(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          VerticalSpacing.medium,
                          CustomDropdownInput<DropdownValueModel>(
                            items: viewModel.genderOptions,
                            value: viewModel.selectedGender,
                            label: LanguageKeys.gender.tr(),
                            tooltip: 'Select your gender',
                            onChanged: (value) {
                              viewModel.updateSelectedGender(value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select gender';
                              }
                              return null;
                            },
                          ),
                          VerticalSpacing.medium,
                          CustomDropdownInput<DropdownValueModel>(
                            items: viewModel.countryOptions,
                            value: viewModel.selectedCountry,
                            label: LanguageKeys.country.tr(),
                            tooltip: 'Select your country',
                            onChanged: (value) {
                              viewModel.updateSelectedCountry(value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select country';
                              }
                              return null;
                            },
                          ),
                          VerticalSpacing.medium,
                          CustomInputField(
                            controller: _zipCodeController,
                            label: LanguageKeys.zipCode.tr(),
                            hint: LanguageKeys.zipCode.tr(),
                            tooltip: 'Enter your zip code',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter zip code';
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
                  padding: const EdgeInsets.all(24.0),
                  child: ScreenStateAware(
                    showApiProgressInPlace: true,
                    state: viewModel.screenState,
                    builder: (context) => CustomButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        // TODO: Implement save profile logic
                        context.pop();
                      },
                      text: 'Save',
                      isLoading:
                          viewModel.screenState.value ==
                          ScreenState.apiProgress,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  MyAccountViewModel createViewModel() {
    return ref.read(myAccountViewModel);
  }

  @override
  String screenName() {
    return "Edit Profile Screen";
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/enum/filter_enum.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/visual_progress_picker.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/mmg_msg_equpment_filter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_selection_field.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class UserImageUploadBottomSheet extends ConsumerStatefulWidget {
  final Function(String imageUrl, String msgLevel) onUpload;

  const UserImageUploadBottomSheet({super.key, required this.onUpload});

  @override
  ConsumerState<UserImageUploadBottomSheet> createState() =>
      _UserImageUploadBottomSheetState();
}

class _UserImageUploadBottomSheetState
    extends BaseConsumerState<UserImageUploadBottomSheet, TemplatesViewModel>
    with ImagePickerUtils {
  late ValueNotifier<String> _selectedImage;
  late ValueNotifier<String> _selectedMsgLevel;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImage = ValueNotifier('');
    _selectedMsgLevel = ValueNotifier('');
  }

  @override
  void dispose() {
    _selectedImage.dispose();
    _selectedMsgLevel.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage.value = image.path;
    }
  }

  void _handleUpload() {
    appLog('tap on upload');
    if (_selectedImage.value.isNotEmpty && _selectedMsgLevel.value.isNotEmpty) {
      widget.onUpload(_selectedImage.value ?? '', _selectedMsgLevel.value!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var filterViewModel = ref.read(filterVm([FilterTypes.templateType]));

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY:2 ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'UPLOAD IMAGE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppTheme.titleTextColor,
                ),
              ),
            ),
            Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 20),
            // Image Picker Area (Simplified VisualProgressPicker logic)
            VisualProgressPicker(
              placeHolder: 'Upload Image(Optional)',
              imageNotifier: _selectedImage,
              onPickImage: () => _pickImage(),
              onRemove: () {
                _selectedImage.value = "";
              },
            ),
      
            VerticalSpacing.medium,
      
            // MSG Level Selection
            ValueListenableBuilder<String?>(
              valueListenable: _selectedMsgLevel,
              builder: (context, msgLevel, child) {
                return CustomSelectionField(
                  // tooltipDirectionFixed: true,
                  label: 'Choose Muscle Groups',
                  placeholder: 'Select MSG Level',
                  tooltip: 'Choose which muscle or muscle group this selfie is focused on; so you can later on filter all your images by muscle & see visual progress',
                  labelStyle: TextTheme.of(context).titleSmall,
                  selectedWidget: msgLevel != null
                      ? Text(
                          msgLevel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      : null,
                  trailingIcon: SmartImageView(SvgImageId.iconDownArrow.path),
                  onTap: (position) async {
                    await filterViewModel.getMmgLevel(FilterTypes.mmg);
                    if (!context.mounted) return;
      
                    final result = await showModalBottomSheet<List<int>>(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 112,
                      ),
                      context: context,
                      builder: (context) => MmgFilter(
                        heading: 'MMG',
                        mmgList: filterViewModel.mmgLevelList,
                      ),
                    );
      
                    if (result != null && context.mounted) {
                      final selectedNames = filterViewModel.mmgLevelList
                          .expand((element) => element.filterValues)
                          .where((element) => result.contains(element.id))
                          .map((e) => e.labelName)
                          .join(', ');
      
                      _selectedMsgLevel.value = selectedNames;
                    }
                  },
                );
              },
            ),
      
            VerticalSpacing.mediumExtra,
      
            // Upload Button
            CustomButton(
              text: 'UPLOAD',
              onPressed: _handleUpload,
              backgroundColor: AppTheme.primaryThemeColor,
            ),
            VerticalSpacing.large,
          ],
        ),
      ),
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return TemplatesViewModel();
  }

  @override
  String screenName() {
    return 'UserImageUploadBottomSheet';
  }
}

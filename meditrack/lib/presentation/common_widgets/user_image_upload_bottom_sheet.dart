import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/enum/filter_enum.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/visual_progress_picker.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImage = ValueNotifier('');
  }

  @override
  void dispose() {
    _selectedImage.dispose();
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
    if (_selectedImage.value.isNotEmpty) {
      widget.onUpload(_selectedImage.value, "");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // var filterViewModel = ref.read(filterVm([FilterTypes.templateType]));

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

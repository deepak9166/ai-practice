import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/core/utils/image_picker_utils.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/user_image_upload_bottom_sheet.dart';
import 'package:meditrack/presentation/common_widgets/visual_progress_picker.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/base/screen_state_aware.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/language_keys.dart';
import '../../../core/utils/validators.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_input_field.dart';
import '../../common_widgets/spacing_widgets.dart';
import '../../providers/vm_provider.dart';
import '../base/screen_state.dart';
import 'view_model/my_account_view_model.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState
    extends BaseConsumerState<ContactUsScreen, MyAccountViewModel>
    with ImagePickerUtils {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final ValueNotifier<String> _selectedImage = ValueNotifier('');

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _selectedImage.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // final XFile? image = await pickImage(context);
    // if (image != null) {
    //   final file = File(image.path);
    //   final size = await file.length();
    //   if (size > 10 * 1024 * 1024) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(const SnackBar(content: Text('File size exceeds 10MB')));
    //     return;
    //   }
    //   _selectedImage.value = image;
    // }

    showModalBottomSheet(
      context: context,
      builder: (context) => UserImageUploadBottomSheet(
        onUpload: (imageUrl, msgLevel) {
          appLog('Image URL: $imageUrl, MSG Level: $msgLevel');
          _selectedImage.value = imageUrl;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LanguageKeys.contactUs.tr()),
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
                        controller: _fullNameController,
                        label: LanguageKeys.fullName.tr(),
                        hint: LanguageKeys.fullName.tr(),
                        keyboardType: TextInputType.name,
                        validator: Validators.validateName,
                      ),
                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _emailController,
                        label: LanguageKeys.email.tr(),
                        hint: LanguageKeys.email.tr(),
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      VerticalSpacing.medium,
                      CustomInputField(
                        controller: _messageController,
                        label: LanguageKeys.description.tr(),
                        hint: LanguageKeys.description.tr(),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.medium,
                      ValueListenableBuilder<String?>(
                        valueListenable: _selectedImage,
                        builder: (context, image, child) {
                          return VisualProgressPicker(
                            title: 'Media Upload',
                            subtitle:
                                'Upload images or videos (JPG, PNG, MP4, PDF, DOC). Max total size: 10MB.',
                            placeHolder: 'Upload image(JPG/PNG)',
                            imageNotifier: _selectedImage,
                            onPickImage: () => _pickImage(),
                            onRemove: () {
                              
                            },
                          );
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await viewModel.sendContactUs(
                      fullName: _fullNameController.text,
                      email: _emailController.text,
                      message: _messageController.text,
                      attachmentPath: _selectedImage.value,
                    );
                    if (viewModel.screenState.value == ScreenState.content) {
                      // ignore: use_build_context_synchronously
                      AppRouter.pop(context);
                    }
                  },
                  text: LanguageKeys.submit.tr(),
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
  MyAccountViewModel createViewModel() {
    return ref.read(myAccountViewModel);
  }

  @override
  String screenName() {
    return "Contact Us Screen";
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/constants/language_keys.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/my_account/view_model/my_account_view_model.dart';

/// Home Screen
///
/// Main screen displayed after successful authentication.
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileState();
}

class _MyProfileState
    extends BaseConsumerState<MyProfileScreen, MyAccountViewModel> {
  @override
  MyAccountViewModel createViewModel() {
    return ref.read(myAccountViewModel);
  }

  @override
  String screenName() {
    return "MyProfile in screen";
  }

  @override
  Widget build(BuildContext context) {
    // final locale = ref.watch(languageProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LanguageKeys.myProfile.tr()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageKeys.personalDetails.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: SmartImageView(SvgImageId.edit.path),
                    onPressed: () {
                      AppRouter.push(context, AppConstants.routeEditProfile);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white, height: 2),

              /// Details List
              _profileItem(
                icon: SmartImageView(SvgImageId.fullName.path),
                title: LanguageKeys.fullName.tr(),
                value: 'Debra Halt',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.phone.path),
                title: LanguageKeys.phoneNumber.tr(),
                value: '+132497584',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.email.path),
                title: LanguageKeys.email.tr(),
                value: 'Workouttracker@gmail.com',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.age.path),
                title: LanguageKeys.age.tr(),
                value: '22 Years',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.DOB.path),
                title: LanguageKeys.DOB.tr(),
                value: '12-10-2003',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.gender.path),
                title: LanguageKeys.gender.tr(),
                value: 'Male',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.nationality.path),
                title: LanguageKeys.nationality.tr(),
                value: 'Indian',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.country.path),
                title: LanguageKeys.country.tr(),
                value: 'India',
              ),
              _profileItem(
                icon: SmartImageView(SvgImageId.zipCode.path),
                title: LanguageKeys.zipCode.tr(),
                value: '332544',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileItem({
    required Widget icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.titleTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.descriptionTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

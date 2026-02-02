import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_popup_dialog.dart';
import 'package:meditrack/presentation/providers/auth_provider.dart';
import 'package:meditrack/presentation/providers/local_storage_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/language_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../common_widgets/smart_image_view.dart';
import '../../../config/svg_config.dart';

class AccountOption {
  final SvgImageId icon;
  final String titleKey;
  final VoidCallback? onTap;

  const AccountOption({required this.icon, required this.titleKey, this.onTap});
}

class MyAccountScreen extends ConsumerWidget {
  const MyAccountScreen({super.key});

  List<AccountOption> _getAccountOptions(
    BuildContext context,
    AuthStateNotifier auth,
  ) {
    return [
      AccountOption(
        icon: SvgImageId.myAccount,
        titleKey: LanguageKeys.myProfile,
        onTap: () => context.push(AppConstants.routeMyProfile),
      ),
      AccountOption(
        icon: SvgImageId.changePassword,
        titleKey: LanguageKeys.changePassword,
        onTap: () => context.push(AppConstants.routeChangePassword),
      ),
      AccountOption(
        icon: SvgImageId.contactUs,
        titleKey: LanguageKeys.contactUs,
        onTap: () => context.push(AppConstants.routeContactUs),
      ),
      AccountOption(
        icon: SvgImageId.aboutUs,
        titleKey: LanguageKeys.termsAndConditions,
        onTap: () => context.push(AppConstants.routeTermsAndConditions),
      ),
      AccountOption(
        icon: SvgImageId.privacyPolicy,
        titleKey: LanguageKeys.privacyPolicy,
        onTap: () => context.push(AppConstants.routePrivacyPolicy),
      ),
      AccountOption(
        icon: SvgImageId.aboutUs,
        titleKey: LanguageKeys.aboutUs,
        onTap: () => context.push(AppConstants.routeAboutUs),
      ),
      AccountOption(
        icon: SvgImageId.faq,
        titleKey: LanguageKeys.faq,
        onTap: () => context.push(AppConstants.routeFaq),
      ),
      AccountOption(
        icon: SvgImageId.deleteAccount,
        titleKey: LanguageKeys.deleteAccount,
        onTap: () async {
          await CustomPopupDialog.show(
            context: context,
            content: LanguageKeys.areYouSureYouWantToDeleteThisAccount.tr(),
            icon: SmartImageView(SvgImageId.delete.path),
            actions: [
              DialogAction(
                text: LanguageKeys.cancel.tr(),
                onPressed: () {
                  // Handle cancel
                },
              ),
              DialogAction(
                text: LanguageKeys.delete.tr(),
                onPressed: () async {
                  // Handle delete account
                },
                isDestructive: true,
                isPrimary: true,
              ),
            ],
          );
        },
      ),
      AccountOption(
        icon: SvgImageId.logout,
        titleKey: LanguageKeys.logout,
        onTap: () async {
          await CustomPopupDialog.show(
            context: context,
            content: LanguageKeys.areYouSureYouWantToLogoutThisAccount.tr(),
            icon: SmartImageView(SvgImageId.logoutPop.path),
            actions: [
              DialogAction(
                text: LanguageKeys.cancel.tr(),
                onPressed: () {
                  // Handle cancel
                },
              ),
              DialogAction(
                text: LanguageKeys.logout.tr(),
                onPressed: () async {
                  // Handle logout
                  await auth.logout();
                  AppRouter.go(context, AppConstants.routeSignIn);
                },
                isDestructive: false,
                isPrimary: true,
              ),
            ],
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var auth = ref.read(authStateNotifierProvider.notifier);
    final accountOptions = _getAccountOptions(context, auth);

    return Scaffold(
      appBar: CustomAppBar(title: LanguageKeys.myAccount.tr()),
      body: ListView.builder(
        itemCount: accountOptions.length,
        itemBuilder: (context, index) {
          final option = accountOptions[index];
          return Column(
            children: [
              ListTile(
                leading: SmartImageView(option.icon.path),
                title: Text(
                  option.titleKey.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                trailing: SmartImageView(SvgImageId.arrowRight.path),
                onTap: option.onTap,
                visualDensity: VisualDensity(vertical: 2),
              ),
              if (index < accountOptions.length - 1)
                Divider(color: AppTheme.dividerColor, height: 0),
            ],
          );
        },
      ),
    );
  }
}

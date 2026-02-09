import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/language_keys.dart';
import '../../config/svg_config.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../providers/vm_provider.dart';
import 'smart_image_view.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static Widget getInitialsAvatar(String name, BuildContext context) {

    return CircleAvatar(
      radius: 40,
      backgroundColor: AppTheme.lightThemeColro, // You can customize the color
      child: Text(
        name.firstTwoLetter,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var items = [
      DrawerHeader(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(
            //   backgroundImage: AssetImage(SvgImageId.myAccount.path),
            //   radius: 40,
            // ),
            getInitialsAvatar('User Name', context),
            SizedBox(height: 10),
            Text(
              'User Name',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              'abc@gmail.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.myAccount.path),
        title: Text(
          LanguageKeys.myAccount.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeMyAccount);
        },
      ),
      ExpansionTile(
        leading: SmartImageView(SvgImageId.appConfiguration.path),
        title: Text(
          LanguageKeys.appConfiguration.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        initiallyExpanded: ref.watch(appConfigExpandedProvider),
        backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        onExpansionChanged: (expanded) =>
            ref.read(appConfigExpandedProvider.notifier).state = expanded,
        trailing: ref.watch(appConfigExpandedProvider)
            ? SmartImageView(SvgImageId.arrowUp.path)
            : SmartImageView(SvgImageId.arrowRight.path),

        children: [
          Divider(height: 1),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              tileColor: Colors.white,

              dense: true,
              visualDensity: VisualDensity(vertical: -4),
              leading: SizedBox(width: 20),
              title: Text(
                LanguageKeys.mmg.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
              onTap: () {
                AppRouter.push(context, AppConstants.routeEditMmgLevel);
              },
            ),
          ),
          Divider(height: 0),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -4),
              leading: SizedBox(width: 20),
              title: Text(
                LanguageKeys.metricsPreferences.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
              onTap: () {
                AppRouter.push(context, AppConstants.routeEditPreferenceUnit);
              },
            ),
          ),
          Divider(height: 0),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              dense: true,
              selected: true,
              visualDensity: VisualDensity(vertical: -4),
              leading: SizedBox(width: 20),
              title: Text(
                LanguageKeys.myFitnessGoals.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
              onTap: () {
                AppRouter.pop(context);
                AppRouter.push(context, AppConstants.routeFitnessGoals);
              },
            ),
          ),
        ],
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.manageAccess.path),
        title: Text(
          LanguageKeys.manageAccess.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeManageAccess);
        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.recievedAccess.path),
        title: Text(
          LanguageKeys.receivedAccessRequest.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeReceivedAccessRequest);
        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.myMeasurements.path),
        title: Text(
          LanguageKeys.myMeasurements.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeMyMeasurement);
        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.gymPhotoVault.path),
        title: Text(
          LanguageKeys.gymPhotoVault.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeGymPhotoVault);

        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.workoutHistory.path),
        title: Text(
          LanguageKeys.workoutHistory.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeWorkoutHistory);
        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.futureWorkScheduling.path),
        title: Text(
          LanguageKeys.futureWorkScheduling.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeFutureWorkScheduling);
        },
      ),
      ListTile(
        leading: SmartImageView(SvgImageId.customAccess.path),
        title: Text(
          LanguageKeys.customExercises.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        trailing: SmartImageView(SvgImageId.arrowRight.path),
        onTap: () {
          AppRouter.pop(context);
          AppRouter.push(context, AppConstants.routeCustomExercise);
        },
      ),
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView.separated(
        itemCount: items.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return items[index];
        },
        separatorBuilder: (context, index) => Divider(height: 0),
      ),
    );
  }
}

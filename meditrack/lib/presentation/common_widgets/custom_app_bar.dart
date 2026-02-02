import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import 'spacing_widgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Icon? backIcon;
  final List<Widget>? actions;
  final bool hideLeading;
  final Widget? defaultAction;
  final String? defaultActionTitle;
  final VoidCallback? onDefaultActionPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.backIcon,
    this.actions,
    this.hideLeading = false,
    this.defaultAction,
    this.defaultActionTitle,
    this.onDefaultActionPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Widget defaultFinishAction = Container(
      constraints: const BoxConstraints(maxWidth: 90, maxHeight: 25),
      child: OutlinedButton(
        onPressed: onDefaultActionPressed ?? () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          defaultActionTitle ?? '',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    final List<Widget>? appBarActions =
        actions ??
        (defaultActionTitle?.isNotEmpty ?? false
            ? (defaultAction != null
                  ? [defaultAction!]
                  : [defaultFinishAction, HorizontalSpacing.medium])
            : null);

    return AppBar(
      leading: hideLeading
          ? null
          : IconButton(
              icon: backIcon ?? Icon(Icons.arrow_back_ios_new),
              onPressed:
                  onBack ??
                  () {
                    print('CustomAppBar back button pressed');
                    AppRouter.pop(context);
                  },
            ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: AppTheme.titleTextColor,
        ),
      ),
      centerTitle: true,
      actions: appBarActions,
    );
  }
}

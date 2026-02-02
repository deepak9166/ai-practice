import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';

/// A customizable popup dialog widget for common use cases in the app.

class CustomPopupDialog extends StatelessWidget {
  const CustomPopupDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
    this.icon,
    this.barrierDismissible = true,
  });

  /// The title of the dialog. If null, no title is shown.
  final String? title;

  /// The content of the dialog. Can be a string or a custom widget.
  /// If a string is provided, it will be displayed as text.
  /// If a widget is provided, it will be displayed directly.
  final dynamic content;

  /// List of action buttons. Each action has a text label and an onPressed callback.
  final List<DialogAction> actions;

  /// Optional icon displayed above the title.
  final Widget? icon;

  /// Whether the dialog can be dismissed by tapping outside.
  final bool barrierDismissible;

  /// Shows the dialog using [showDialog].
  ///
  /// [context] - The build context.
  /// Returns a Future that completes when the dialog is dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    dynamic content,
    List<DialogAction> actions = const [],
    Widget? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,

      barrierDismissible: barrierDismissible,
    
      builder: (context) =>  BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY:2 ),
        child: CustomPopupDialog(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        barrierDismissible: barrierDismissible,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: icon != null || title != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(height: 16)],
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            )
          : null,
      content: content is Widget
          ? content
          : content is String
          ? Text(
              content,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.titleTextColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            )
          : null,
      actions: actions.isNotEmpty
          ? [
              Row(
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: actions[i].isPrimary
                            ? OutlinedButton(
                                onPressed: () {
                                  actions[i].onPressed?.call();
                                  if (actions[i].dismissOnTap) {
                                    Navigator.of(
                                      context,
                                    ).pop(actions[i].result);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary, // border color
                                    width: 1,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  actions[i].text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  actions[i].onPressed?.call();
                                  if (actions[i].dismissOnTap) {
                                    Navigator.of(
                                      context,
                                    ).pop(actions[i].result);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black),
                                  foregroundColor: actions[i].isDestructive
                                      ? Colors.red
                                      : Colors.black,
                                ),
                                child: Text(
                                  actions[i].text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (i != actions.length - 1) const SizedBox(width: 15),
                  ],
                ],
              ),
            ]
          : null,
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

/// Represents an action button in the dialog.
class DialogAction {
  const DialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.dismissOnTap = true,
    this.result,
  });

  /// The text displayed on the button.
  final String text;

  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether this is the primary action (uses elevated button style like CustomButton).
  final bool isPrimary;

  /// Whether this action is destructive (e.g., delete).
  /// Affects the button's color when not primary.
  final bool isDestructive;

  /// Whether tapping this button should dismiss the dialog.
  final bool dismissOnTap;

  /// The result to return when the dialog is dismissed.
  final dynamic result;
}

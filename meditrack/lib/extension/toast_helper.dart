import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
extension ToastHelper on BuildContext{
/// Show Success Toast
  void showSuccess(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      textColor: Colors.white,
    );
  }

  /// Show Error Toast
  void showError(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      textColor: Colors.white,
    );
  }

  /// Show Info Toast
  void showInfo(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      textColor: Colors.white,
    );
  }

  /// Show Warning Toast
  void showWarning(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      textColor: Colors.white,
    );
  }

  // Private helper
  void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color textColor,
  }) {
    FToast fToast = FToast();
    fToast.init(this);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
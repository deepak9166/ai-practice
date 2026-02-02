import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rotation Notifier
///
/// Manages device orientation/rotation settings.
/// Allows users to lock/unlock screen rotation.
class RotationNotifier extends StateNotifier<bool> {
  RotationNotifier() : super(true) {
    _loadRotation();
  }

  /// Load saved rotation preference
  ///  Implement actual storage retrieval
  void _loadRotation() {
    // Example: final savedRotation = SharedPreferences.getInstance()
    //   .then((prefs) => prefs.getBool(AppConstants.rotationKey));
    // if (savedRotation != null) state = savedRotation;
  }

  /// Toggle rotation lock
  ///
  /// [enabled] - true to allow rotation, false to lock portrait
  Future<void> setRotation(bool enabled) async {
    state = enabled;
    await _applyRotation();
    _saveRotation();
  }

  /// Apply rotation settings to device
  Future<void> _applyRotation() async {
    if (state) {
      // Allow all orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Lock to portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  /// Save rotation preference
  /// Implement actual storage
  void _saveRotation() {
    // Example: SharedPreferences.getInstance()
    //   .then((prefs) => prefs.setBool(AppConstants.rotationKey, state));
  }
}

/// Rotation Provider
///
/// Provides rotation state to the application.
final rotationProvider = StateNotifierProvider<RotationNotifier, bool>((ref) {
  return RotationNotifier();
});

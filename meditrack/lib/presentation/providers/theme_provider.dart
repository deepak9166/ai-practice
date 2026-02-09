import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

/// Theme Mode Notifier
///
/// Manages the application theme (light/dark mode).
/// Persists theme preference and notifies listeners of changes.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Load saved theme preference
  /// Implement actual storage retrieval
  void _loadTheme() {
    // Example: final savedTheme = SharedPreferences.getInstance()
    //   .then((prefs) => prefs.getString(AppConstants.themeKey));
    // if (savedTheme == 'dark') state = ThemeMode.dark;
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
  }

  /// Set theme mode
  void setTheme(ThemeMode mode) {
    state = mode;
    _saveTheme();
  }

  /// Save theme preference
  ///  Implement actual storage
  void _saveTheme() {
    // Example: SharedPreferences.getInstance()
    //   .then((prefs) => prefs.setString(AppConstants.themeKey, state.toString()));
  }
}

/// Theme Provider
///
/// Provides ThemeMode state to the application.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Theme Data Provider
///
/// Provides the appropriate ThemeData based on current theme mode.
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
});

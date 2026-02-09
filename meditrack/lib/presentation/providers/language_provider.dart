import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/providers/local_storage_provider.dart';

/// Language Notifier
///
/// Manages the application language/locale.
/// Supports multiple languages and persists user preference.
class LanguageNotifier extends StateNotifier<Locale> {
  LocalStorageService localStorageService;
  AuthStateNotifier authStateNotifier;
  LanguageNotifier(this.localStorageService, this.authStateNotifier)
    : super(const Locale('en', 'US')) {
    _loadLanguage();
  }

  /// Available languages
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish (example)
    Locale('fr', 'FR'), // French (example)
    Locale('hi', 'IN'), // Hindi (example)
  ];

  /// Load saved language preference
  /// Implement actual storage retrieval
  Future<void> _loadLanguage() async {
    // Example:
    final savedLang = await localStorageService.getLanguageCode();
    if (savedLang != null) state = Locale(savedLang);

   

    state = _findSupportedLocale(savedLang ?? "en");

     appLog("load  lng provider ${state.countryCode}");
  }

    Future<Locale> getLanguageCode() async {
    // Example:
    final savedLang = await localStorageService.getLanguageCode();
    if (savedLang != null) state = Locale(savedLang);

   

    return _findSupportedLocale(savedLang ?? "en");
  }

  /// Set application language
  void setLanguage(Locale locale, BuildContext context) {
    if (supportedLocales.contains(locale)) {
      context.setLocale(locale);
      state = locale;
      _saveLanguage(locale);
    } 
  }

  /// Save language preference
  /// Implement actual storage
  Future<void> _saveLanguage(Locale locale) async {
    appLog("locale.languageCode ${locale.languageCode}");
    await authStateNotifier.saveLanguage(locale.languageCode);
  }

  /// Get current language code
  String get currentLanguageCode => state.languageCode;

  /// Helper: Find supported locale or fallback
  Locale _findSupportedLocale(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale('en'),
    );
  }
}

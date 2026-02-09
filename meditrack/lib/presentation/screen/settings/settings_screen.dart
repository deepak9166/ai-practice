import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/rotation_provider.dart';

/// Settings Screen
///
/// Screen for managing application settings including:
/// - Theme (Light/Dark)
/// - Language
/// - Device Rotation
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);
    final rotationEnabled = ref.watch(rotationProvider);
    final localService = ref.read(localStorageServiceProvider);

    return Scaffold(
      appBar: AppBar(title:  Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section
          _buildSectionHeader('Theme'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
              ),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(themeProvider.notifier)
                    .setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          const SizedBox(height: 16),

          // Language Section
          _buildSectionHeader('Language'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Current Language'),
                  subtitle: Text(_getLanguageName(currentLocale.languageCode)),
                ),
                const Divider(height: 1),
                ...LanguageNotifier.supportedLocales.map((locale) {
                  return RadioListTile<Locale>(
                    title: Text(_getLanguageName(locale.languageCode)),
                    value: locale,
                    groupValue: currentLocale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        ref.read(languageProvider.notifier).setLanguage(value, context);
                        context.setLocale(value);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rotation Section
          _buildSectionHeader('Device Rotation'),
          Card(
            child: SwitchListTile(
              title: const Text('Allow Rotation'),
              subtitle: Text(
                rotationEnabled
                    ? 'Device can rotate freely'
                    : 'Locked to portrait mode',
              ),
              value: rotationEnabled,
              onChanged: (value) {
                ref.read(rotationProvider.notifier).setRotation(value);
              },
              secondary: Icon(
                rotationEnabled
                    ? Icons.screen_rotation
                    : Icons.screen_lock_portrait,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Navigation
          ElevatedButton.icon(
            onPressed: () async {
              await localService.deleteTokens();
              // ignore: use_build_context_synchronously
              AppRouter.go(context, AppConstants.routeSignIn);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'hi':
        return 'हिन्दी';
      default:
        return code.toUpperCase();
    }
  }
}

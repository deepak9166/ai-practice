import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/firebase_options.dart';
import 'config/app_config.dart' show AppConfig, AppEnvironment;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/network/services/api_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/vm_provider.dart';

/// Main Entry Point
///
/// Initializes the application with:
/// - Environment configuration
/// - API service
/// - Riverpod state management
/// - Localization
/// - Theme management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await AppConfig.initialize(env: AppEnvironment.dev);

  // Initialize API service
  ApiService.instance.initialize();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize rotation settings
  await _initializeRotation();

  // Firebase Setup
  _firebaseSetup();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
        Locale('hi', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

/// Initialize device rotation based on saved preference
Future<void> _initializeRotation() async {
  // Default to allowing rotation
  // Actual preference will be loaded by RotationProvider
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

/// Initialize Firebase setup
Future<void> _firebaseSetup() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Root Application Widget
///
/// Wraps the application with necessary providers and configurations.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeData = ref.watch(themeDataProvider);
    final locale = ref.watch(languageProvider);

    // This forces EasyLocalization to use Riverpod's locale
    // and triggers rebuild of the WHOLE app tree automatically
    EasyLocalization.of(context)?.setLocale(locale);

    return MaterialApp.router(
      title: 'Into Fitness',
      debugShowCheckedModeBanner: false,
      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: locale,

      // Theme
      theme: themeData,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing
      routerConfig: AppRouter.router,
    );
  }
}

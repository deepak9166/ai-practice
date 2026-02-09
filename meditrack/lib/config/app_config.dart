import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment type enum
enum AppEnvironment { dev, stage, production, demmy }

/// App Configuration Manager
///
/// This class is responsible for loading and managing environment-specific
/// configuration values from .env files. It provides a centralized way to
/// access configuration values throughout the application.
class AppConfig {
  AppConfig._();

  /// Current environment
  static AppEnvironment get environment {
    final env = dotenv.env['ENV'] ?? 'dev';
    switch (env) {
      case 'stage':
        return AppEnvironment.stage;
      case 'production':
        return AppEnvironment.production;
      default:
        return isUseDummyApi ? AppEnvironment.demmy : AppEnvironment.dev;
    }
  }

  /// API Base URL from environment
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// API Timeout in milliseconds
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// Log Level
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'debug';

  /// Initialize configuration by loading the appropriate .env file
  ///
  /// [env] - The environment to load (dev, stage, or production)
  static Future<void> initialize({
    AppEnvironment env = AppEnvironment.dev,
  }) async {
    String envFile;
    switch (env) {
      case AppEnvironment.stage:
        envFile = 'config/env/stage.env';
        break;
      case AppEnvironment.production:
        envFile = 'config/env/prod.env';
        break;
      default:
        envFile = 'config/env/dev.env';
    }
    await dotenv.load(fileName: envFile);
  }

  /// Check if current environment is development
  static bool get isDevelopment => environment == AppEnvironment.dev;

  /// Check if current environment is staging
  static bool get isStaging => environment == AppEnvironment.stage;

  /// Check if current environment is production
  static bool get isProduction => environment == AppEnvironment.production;

  /// Check if current environment is demmy api
  static bool get isUseDummyApi => true;
}

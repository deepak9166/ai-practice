import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';


/// Keys for stored values
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String themeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String languageCode = 'language_code';
  static const String isNotificationsEnabled = 'notifications_enabled';
  static const String userSettings =
      'user_settings'; // JSON string for complex settings
}

// Simple auth state
class AuthState {
  final bool isAuthenticated;
  final String? accessToken;
  final bool? isDarkTheme;
  final String? languageCode;

  AuthState({
    required this.isAuthenticated,
    this.accessToken,
    this.isDarkTheme,
    this.languageCode,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    bool? isDarkTheme,
    String? languageCode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

// Auth State Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final LocalStorageService storage;

  AuthStateNotifier(this.storage) : super(AuthState(isAuthenticated: false)) {
    checkAuthStatus(); // Load on init
    checkConfig();
  }

  checkConfig(){



  }

  /// Check if user is authenticated by reading token
  Future<void> checkAuthStatus() async {
    final token = await storage.getAccessToken();
    final langCode = await storage.getLanguageCode();
    final theme = await storage.getThemeMode();
    state = state.copyWith(
      isAuthenticated: token != null && token.isNotEmpty,
      accessToken: token,
      isDarkTheme: theme == "DarkMode",
      languageCode: langCode,
    );
  }

  /// Login: save token and update state
  Future<void> login(String accessToken, [String? refreshToken]) async {
    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
   await checkAuthStatus();
  }

  /// Logout: clear token and update state
  Future<void> logout() async {
    await storage.deleteTokens();
    state = state.copyWith(isAuthenticated: false, accessToken: null);
  }

  Future<void> saveLanguage(String langCode) async {
    await storage.saveLanguageCode(langCode);
  }


}

/// Singleton service for secure local storage
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // === Token Management ===
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);
  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> deleteTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  // === Theme ===
  Future<void> saveThemeMode(String mode) async {
    // 'light' | 'dark' | 'system'
    await _storage.write(key: StorageKeys.themeMode, value: mode);
  }

  Future<String> getThemeMode() async {
    return await _storage.read(key: StorageKeys.themeMode) ?? 'system';
  }

  // === Language ===
  Future<void> saveLanguageCode(String code) async {
    await _storage.write(key: StorageKeys.languageCode, value: code);
  }

  Future<String?> getLanguageCode() async {
    return await _storage.read(key: StorageKeys.languageCode);
  }

  // === Notifications ===
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _storage.write(
      key: StorageKeys.isNotificationsEnabled,
      value: enabled.toString(),
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final value = await _storage.read(key: StorageKeys.isNotificationsEnabled);
    return value == 'true';
  }

  // === Generic Settings (Map/String) ===
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.write(
      key: StorageKeys.userSettings,
      value: jsonEncode(settings),
    );
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final jsonStr = await _storage.read(key: StorageKeys.userSettings);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // === Generic Helpers ===
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearAll() => _storage.deleteAll();
}

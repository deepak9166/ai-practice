import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import '../../data/network/repositories/auth_repository.dart';
import '../../core/service/api_service.dart';
import 'local_storage_provider.dart';

/// Auth Repository Provider
///
/// Provides a singleton instance of AuthRepository to be used
/// throughout the application via Riverpod dependency injection.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ApiService.instance;
  return AuthRepository(apiService);
});

/// Auth State Provider
///
/// Manages the authentication state of the user.
/// Can be extended to include user data, tokens, etc.

final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return AuthStateNotifier(storage);
});
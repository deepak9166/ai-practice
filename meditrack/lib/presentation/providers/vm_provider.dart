import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/screens/add_workout/view_model/add_workout_viewmodel.dart';
import 'package:meditrack/presentation/screens/landing_app/tab_excercise/filter/filter_view_model.dart';
import 'package:meditrack/presentation/screens/profile_setup/mmg_level/mmg_level_view_model.dart';
import 'package:meditrack/presentation/screens/custom_exercise/view_model/custom_exercise_view_model.dart';
import 'package:meditrack/presentation/screens/work_scheduling/view_model/scheduling_view_model.dart';
import 'package:meditrack/presentation/screens/workout_history/view_model/workout_history_view_model.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

import '../../data/local/app_database.dart';
import '../../data/network/services/social_login_service.dart';
import '../../enum/filter_enum.dart';
import '../screen/auth/forgot_password/forgot_password_view_model.dart';
import '../screen/auth/sign_in/sign_in_viewmodel.dart';
import '../screen/auth/sign_up/sign_up_view_model.dart';
import '../screen/landing/add_medicine/add_medicine_view_model.dart';
import '../screen/landing/landing_view_model.dart';
import '../screens/my_account/view_model/my_account_view_model.dart';
import 'auth_provider.dart';
import 'language_provider.dart';
import 'local_storage_provider.dart';
import 'safe_execute_provider.dart';

/// Manages the home screen state of app.
final homeViewModel = Provider<LandingViewModel>((ref) {
  final authStateService = ref.watch(authStateNotifierProvider);
  return LandingViewModel(authStateService);
});

/// Manages the my account screen state of app.
final myAccountViewModel = ChangeNotifierProvider<MyAccountViewModel>((ref) {
  final authStateService = ref.watch(authStateNotifierProvider);
  return MyAccountViewModel(authStateService);
});

/// App Configuration Expansion State
final appConfigExpandedProvider = StateProvider<bool>((ref) => false);

/// Sign In ViewModel Provider
final signInViewModelProvider = Provider.autoDispose<SignInViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authStateService = ref.watch(authStateNotifierProvider.notifier);
  var googleService = GoogleAuthService();
  var facebookAuthService = FacebookAuthService();
  return SignInViewModel(authRepository, authStateService,googleService,facebookAuthService);
});

/// Sign Up ViewModel Provider
final signUpVm = Provider.autoDispose<SignUpViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpViewModel(authRepository);
});

/// Forgot password ViewModel Provider
final forgotPasswordVm = Provider.autoDispose<ForgotPasswordViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordViewModel(authRepository);
});

// Tap Action Singleton provider
final actionThrottleProvider = Provider<ActionThrottleService>((ref) {
  final service = ActionThrottleService();
  // Optional: ref.onDispose(service.dispose);
  return service;
});

// Local Storage Riverpod provider (singleton)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Language Provider
///
/// Provides Locale state to the application.
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final authStateService = ref.watch(authStateNotifierProvider.notifier);
  final storage = ref.read(localStorageServiceProvider);
  return LanguageNotifier(storage, authStateService);
});

final mmgLevelViewModel = Provider.autoDispose<MmgLevelViewModel>((ref) {
  return MmgLevelViewModel();
});

final filterVm = Provider.family<FilterViewModel, List<FilterTypes>>((
  ref,
  items,
) {
  return FilterViewModel(items);
});

/// Add Workout ViewModel Provider
final addWorkoutViewModelProvider = Provider.autoDispose<AddWorkoutViewModel>((
  ref,
) {
  return AddWorkoutViewModel();
});

/// Workout Templates ViewModel Provider
final templatesViewModelProvider = Provider.autoDispose<TemplatesViewModel>((
  ref,
) {
  return TemplatesViewModel();
});

final schedulingViewModelProvider = Provider.autoDispose<SchedulingViewModel>((
  ref,
) {
  return SchedulingViewModel();
});

final workoutHistoryViewModelProvider =
    Provider.autoDispose<WorkoutHistoryViewModel>((ref) {
      return WorkoutHistoryViewModel();
    });

final customExerciseViewModel = ChangeNotifierProvider<CustomExerciseViewModel>(
  (ref) {
    return CustomExerciseViewModel();
  },
);

/// NEW DATA

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});


final addMedicineProvider = FutureProvider.family<int, MedicinesCompanion>(
  (ref, medicine) async {
    final db = ref.read(databaseProvider);
    return db.addMedicine(medicine);
  },
);


final addMedicineVm = Provider.autoDispose<AddMedicineViewModel>((
  ref,
) {
  return AddMedicineViewModel();
}); //AddMedicineViewModel
/// Application-wide constants
///
/// This file contains all constant values used throughout the application
/// to maintain consistency and avoid magic numbers/strings.
class AppConstants {
  AppConstants._();

  // API Constants
  static const String apiContentType = 'application/json';
  static const String apiAcceptHeader = 'application/json';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String rotationKey = 'rotation_enabled';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Routes
  static const String routeLanding = '/home';
  static const String routeSignIn = '/sign-in';
  static const String routeSplash = '/splash';
  static const String routeSignUp = '/sign-up';
  static const String routeSignUpVerify = '/sign-up-verify';
  static const String routeForgotPasswordVerify = '/forgot-password-verify';
  static const String routeSignUpSuccess = '/sign-up-success';
  static const String routeSettings = '/settings';
  static const String routeNotification = '/notification';
  static const String routeCalender = '/calender';
  static const String routeWorkoutSummaryCompleted =
      '/workout-summary-completed';
  static const String routeWorkoutSummary = '/workout-summary';
  static const String routeProgressReport = '/progress-report';
  static const String routeIntro = '/intro';
  static const String routeMyAccount = '/my-account';
  static const String routeMyProfile = '/my-profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routeProfileSetup = '/profile-setup';

  /// [SelectPreferenceUnit]
  static const String routeSelectPreferenceUnit = '/select-preference-unit';

  /// [SelectPreferenceUnit]
  static const String routeEditPreferenceUnit = '/edit-preference-unit';

  /// [SelectMMGLevel]
  static const String routeSelectMmgLevel = '/select-mmg-level';

  /// [SelectMMGLevel]
  static const String routeEditMmgLevel = '/edit-mmg-level';

  /// [MMGLevelSetupSuccess]
  static const String profileSetupSuccess =
      '/mmg-level-setup-success'; //MMGLevelSetupSuccess
  static const String routeTermsAndConditions = '/terms-and-conditions';
  static const String routePrivacyPolicy = '/privacy-policy';
  static const String routeAboutUs = '/about-us';
  static const String routeFaq = '/faq';
  static const String routeChangePassword = '/change-password';
  static const String routeContactUs = '/contact-us';
  static const String routeFitnessGoals = '/fitness-goals';
  static const String routeProfileQnAComplete = '/profile_qna_complete_screen';
  static const String routeProfileQnA = '/profile_qna';
  static const String routeTemplateDetail = '/template-detail';
  static const String routeEditTemplate = '/edit-template';
  static const String routeMyMeasurement = '/my-measurement';
  static const String routeMyMeasurementDetail = '/my-measurement-detail';
  static const String routeGymPhotoVault = '/gym-photo-vault';
  static const String routeManageAccess = '/manage-access';
  static const String routeReceivedAccessRequest = '/manage-access-request';
  static const String routeShareTemplates = '/share-templates';
  static const String routeSelectMsgLevel = '/select-msg-level';
  static const String routeExerciseList = '/exercise-list';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeForgotPasswordSuccess = '/forgot-password-success';
  static const String routeMedicineDetail = '/medicine-detail';
  static const String routeUpdateMedicine = '/update-medicine';
  static const String routeMedicineExpenses = '/medicine-expenses';



// Med

  static const String routeFutureWorkScheduling = '/future-work-scheduling';
  static const String routeWorkoutHistory = '/workout-history';
  static const String routeWorkoutHistoryDetail = '/workout-history-detail';
  static const String routeTotalWorkoutSummary = '/total-workout-summary';
  static const String routeMonthlyWorkoutSummary = '/monthly-workout-summary';
  static const String routeWeeklySummary = '/weekly-summary';
  static const String routeWorkoutSummaryCombinations = '/workout-summary-combinations';
  static const String routeWorkoutDetailEdit = '/workout-detail-edit';
  static const String routeCustomExercise = '/custom-exercise';
  static const String routeAddCustomExercise = '/add-custom-exercise';
  static const String routeACustomExerciseWaitingApprovalScreen =
      '/custom-exercise-waiting-approval-screen';
  static const String routeExerciseDetail = '/exercise-detail';
  static const String routeAddWorkout = '/add-workout';
  static const String routeTodayWorkout = '/today-workout';

  // URLs
  static const String webPageTermsAndConditionsUrl =
      'https://flutter.dev/community';
  static const String webPagePrivacyPolicyUrl = 'https://flutter.dev/community';
  static const String webPageAboutUsUrl = 'https://flutter.dev/community';
  static const String webPageFaqUrl = 'https://flutter.dev/community';

}

class AppFont {
  AppFont._();
  // Font family
  static const String redHatDisplay = 'RedHatDisplay';
  static const String bricolageGrotesque = 'BricolageGrotesque';
}

// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../extension/toast_helper.dart';
import '../../presentation/screens/add_workout/add_workout.dart';
import '../../presentation/screens/auth/forgot_password/forgot_password_otp_verify.dart';
import '../../presentation/screens/auth/forgot_password/forgot_password_screen.dart';
import '../../presentation/screens/auth/forgot_password/forgot_password_success.dart';
import '../../presentation/screens/auth/sign_in/sign_in_screen.dart';
import '../../presentation/screens/auth/sign_up/sign_up_screen.dart';
import '../../presentation/screens/auth/sign_up/sign_up_success.dart';
import '../../presentation/screens/auth/sign_up/sign_up_otp_verify.dart';
import '../../presentation/screens/calender/calender_screen.dart';
import '../../presentation/screens/calender/workout_summary_screen.dart';
import '../../presentation/screens/custom_exercise/add_custom_exercise.dart';
import '../../presentation/screens/custom_exercise/custom_exercise.dart';
import '../../presentation/screens/custom_exercise/custom_exercise_waiting_approval.dart';
import '../../presentation/screens/custom_exercise/exercise_detail_screen.dart';
import '../../presentation/screens/gym_photo_vault/gym_photo_vault_screen.dart';
import '../../presentation/screens/landing/landing_screen.dart';
import '../../presentation/screens/intro/intro_screen.dart';
import '../../presentation/screens/landing/tab_my_progress/monthly_summary/monthly_summary_screen.dart';
import '../../presentation/screens/landing/tab_my_progress/progress_report_screen.dart';
import '../../presentation/screens/landing/tab_my_progress/total_workout_summary/total_workout_summary_screen.dart';
import '../../presentation/screens/landing/tab_my_progress/weekly_summary/weekly_summary_screen.dart';
import '../../presentation/screens/manage_access/manage_access_screen.dart';
import '../../presentation/screens/profile_qna/profile_qna_screen.dart';
import '../../presentation/screens/profile_qna/profile_qna_success_screen.dart';
import '../../presentation/screens/received_access_request/received_request_screen.dart';
import '../../presentation/screens/my_account/my_account_screen.dart';
import '../../presentation/screens/my_measurements/measurement_detail_screen.dart';
import '../../presentation/screens/my_measurements/my_measurements_screen.dart';
import '../../presentation/screens/notification/notification_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup_success.dart';
import '../../presentation/screens/my_account/my_profile.dart';
import '../../presentation/screens/my_account/edit_profile_screen.dart';
import '../../presentation/screens/profile_setup/fitness_goal_screen.dart';
import '../../presentation/screens/my_account/terms_and_conditions_screen.dart';
import '../../presentation/screens/my_account/privacy_policy_screen.dart';
import '../../presentation/screens/my_account/about_us_screen.dart';
import '../../presentation/screens/my_account/faq_screen.dart';
import '../../presentation/screens/my_account/change_password_screen.dart';
import '../../presentation/screens/my_account/contact_us_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup.dart';
import '../../presentation/screens/profile_setup/mmg_level/select_mmg_level.dart';
import '../../presentation/screens/profile_setup/select_preference_unit.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/landing/tab_my_progress/total_workout_summary/combinations_screen.dart';
import '../../presentation/screens/templates/edit_template_screen.dart';
import '../../presentation/screens/templates/exercise_list_screen.dart';
import '../../presentation/screens/templates/select_msg_level.dart';
import '../../presentation/screens/templates/share_templates_screen.dart';
import '../../presentation/screens/templates/template_detail_screen.dart';
import '../../presentation/screens/templates/todays_workout.dart';
import '../../presentation/screens/work_scheduling/future_work_scheduling.dart';
import '../../presentation/screens/workout_history/workout_detail_edit.dart';
import '../../presentation/screens/workout_history/workout_history_detail.dart';
import '../../presentation/screens/workout_history/workout_history_screen.dart';
import '../constants/app_constants.dart';

enum AnimationType { slideRight, slideLeft, slideUp, fade, scale, rotate, none }

class AppRouter {
  AppRouter._(); // Private constructor

  // GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeSplash,
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        name: AppConstants.routeSplash,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SplashScreen(),
          animationType: AnimationType.fade,
        ),
      ),
      GoRoute(
        path: AppConstants.routeIntro,
        name: AppConstants.routeIntro,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const IntroScreen(),
          animationType: AnimationType.fade,
        ),
      ),

      GoRoute(
        path: AppConstants.routeSignIn,
        name: AppConstants.routeSignIn,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SignInScreen(),
          animationType: AnimationType.slideLeft,
        ),
      ),

      GoRoute(
        path: AppConstants.routeSignUp,
        name: AppConstants.routeSignUp,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeSignUpVerify,
        name: AppConstants.routeSignUpVerify,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SignUpVerify(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeSignUpSuccess,
        name: AppConstants.routeSignUpSuccess,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SignUpSuccess(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        name: AppConstants.routeForgotPassword,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeForgotPasswordVerify,
        name: AppConstants.routeForgotPasswordVerify,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ForgotPasswordOtpVerify(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeForgotPasswordSuccess,
        name: AppConstants.routeForgotPasswordSuccess,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ForgotPasswordSuccess(),
          animationType: AnimationType.slideRight,
        ),
      ),
      //ForgotPasswordSuccess

      // Profile setup
      GoRoute(
        path: AppConstants.routeProfileSetup,
        name: AppConstants.routeProfileSetup,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ProfileSetup(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeSelectPreferenceUnit,
        name: AppConstants.routeSelectPreferenceUnit,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SelectPreferenceUnit(forEidt: false),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeEditPreferenceUnit,
        name: AppConstants.routeEditPreferenceUnit,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SelectPreferenceUnit(forEidt: true),
          animationType: AnimationType.slideRight,
        ),
      ),

      // MMG Level
      GoRoute(
        path: AppConstants.routeSelectMmgLevel,
        name: AppConstants.routeSelectMmgLevel,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SelectMMGLevel(isForEdit: false),
          animationType: AnimationType.slideRight,
        ),
      ),

      // MMG Edit Level
      GoRoute(
        path: AppConstants.routeEditMmgLevel,
        name: AppConstants.routeEditMmgLevel,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SelectMMGLevel(isForEdit: true),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.profileSetupSuccess,
        name: AppConstants.profileSetupSuccess,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ProfileSetupSuccess(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeLanding,
        name: AppConstants.routeLanding,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const LandingScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeSettings,
        name: AppConstants.routeSettings,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          animationType: AnimationType.slideRight,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeNotification,
        name: AppConstants.routeNotification,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const NotificationScreen(),
          animationType: AnimationType.slideRight,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeCalender,
        name: AppConstants.routeCalender,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const CalenderScreen(),
          animationType: AnimationType.slideRight,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutSummary,
        name: AppConstants.routeWorkoutSummary,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WorkoutSummary(isBestPerformOfDay: false),
          animationType: AnimationType.slideUp,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutSummaryCompleted,
        name: AppConstants.routeWorkoutSummaryCompleted,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WorkoutSummary(isBestPerformOfDay: true),
          animationType: AnimationType.slideUp,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeProgressReport,
        name: AppConstants.routeProgressReport,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ProgressReportScreen(),
          animationType: AnimationType.slideUp,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppConstants.routeMyAccount,
        name: AppConstants.routeMyAccount,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const MyAccountScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeMyProfile,
        name: AppConstants.routeMyProfile,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const MyProfileScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeEditProfile,
        name: AppConstants.routeEditProfile,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeFitnessGoals,
        name: AppConstants.routeFitnessGoals,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const FitnessGoalScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeTermsAndConditions,
        name: AppConstants.routeTermsAndConditions,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const TermsAndConditionsScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeAboutUs,
        name: AppConstants.routeAboutUs,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const AboutUsScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeFaq,
        name: AppConstants.routeFaq,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const FaqScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeChangePassword,
        name: AppConstants.routeChangePassword,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeContactUs,
        name: AppConstants.routeContactUs,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ContactUsScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routePrivacyPolicy,
        name: AppConstants.routePrivacyPolicy,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeProfileQnAComplete,
        name: AppConstants.routeProfileQnAComplete,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ProfileQnaSuccessScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeProfileQnA,
        name: AppConstants.routeProfileQnA,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: ProfileQnaScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeTemplateDetail,
        name: AppConstants.routeTemplateDetail,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const TemplateDetailScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeEditTemplate,
        name: AppConstants.routeEditTemplate,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const EditTemplateScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeExerciseList,
        name: AppConstants.routeExerciseList,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ExerciseListScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeMyMeasurement,
        name: AppConstants.routeMyMeasurement,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const MyMeasurementsScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeMyMeasurementDetail,
        name: AppConstants.routeMyMeasurementDetail,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const MeasurementDetailScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeSelectMsgLevel,
        name: AppConstants.routeSelectMsgLevel,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const SelectMsgLevelScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeGymPhotoVault,
        name: AppConstants.routeGymPhotoVault,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const GymPhotoVaultScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeShareTemplates,
        name: AppConstants.routeShareTemplates,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ShareTemplatesScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeManageAccess,
        name: AppConstants.routeManageAccess,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ManageAccessScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeReceivedAccessRequest,
        name: AppConstants.routeReceivedAccessRequest,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const ReceivedAccessRequestScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),

      GoRoute(
        path: AppConstants.routeFutureWorkScheduling,
        name: AppConstants.routeFutureWorkScheduling,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const FutureWorkScheduling(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeAddWorkout,
        name: AppConstants.routeAddWorkout,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const AddWorkoutScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeTodayWorkout,
        name: AppConstants.routeTodayWorkout,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const TodaysWorkoutScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutHistory,
        name: AppConstants.routeWorkoutHistory,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WorkoutHistoryScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutHistoryDetail,
        name: AppConstants.routeWorkoutHistoryDetail,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WorkoutHistoryDetail(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeTotalWorkoutSummary,
        name: AppConstants.routeTotalWorkoutSummary,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const TotalWorkoutSummaryScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeMonthlyWorkoutSummary,
        name: AppConstants.routeMonthlyWorkoutSummary,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const MonthlySummaryScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeWeeklySummary,
        name: AppConstants.routeWeeklySummary,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WeeklySummaryScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutSummaryCombinations,
        name: AppConstants.routeWorkoutSummaryCombinations,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const CombinationsScreen(),
          animationType: AnimationType.slideLeft,
        ),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutDetailEdit,
        name: AppConstants.routeWorkoutDetailEdit,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const WorkoutDetailEdit(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeCustomExercise,
        name: AppConstants.routeCustomExercise,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const CustomExercise(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeAddCustomExercise,
        name: AppConstants.routeAddCustomExercise,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const AddCustomExercise(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeACustomExerciseWaitingApprovalScreen,
        name: AppConstants.routeACustomExerciseWaitingApprovalScreen,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: const CustomExerciseWaitingApprovalScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
      GoRoute(
        path: AppConstants.routeExerciseDetail,
        name: AppConstants.routeExerciseDetail,
        pageBuilder: (context, state) => animatedPage(
          key: state.pageKey,
          child: ExerciseDetailScreen(),
          animationType: AnimationType.slideRight,
        ),
      ),
    ],
  );

  // Global animation duration
  static const Duration _duration = Duration(milliseconds: 350);

  // Custom transition page with your favorite animations
  static CustomTransitionPage<T> animatedPage<T>({
    required LocalKey key,
    required Widget child,
    required AnimationType animationType,
    Duration duration = _duration,
    Curve curve = Curves.easeInOut,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (animationType) {
          case AnimationType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );
          case AnimationType.slideLeft:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );

          case AnimationType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );

          case AnimationType.fade:
            return FadeTransition(opacity: animation, child: child);

          case AnimationType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.85,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );

          case AnimationType.rotate:
            return RotationTransition(
              turns: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                ),
                child: child,
              ),
            );

          case AnimationType.none:
            return child;
        }
      },
    );
  }

  //// Helper methods — now even cleaner! Use [AppConstants.yourRouteName]
  static void go(BuildContext context, String location) => context.go(location);
  //// Helper methods — now even cleaner! Use [AppConstants.yourRouteName]
  static void push(BuildContext context, String location, {Object? extra}) =>
      context.push(location, extra: extra);
  //// Helper methods — now even cleaner! Use [AppConstants.yourRouteName]
  static void pushReplacement(BuildContext context, String location) =>
      context.pushReplacement(location);
  //// Helper methods — now even cleaner! Use [AppConstants.yourRouteName]
  static void pop(BuildContext context, {dynamic argument}) =>
      context.pop(argument);
}

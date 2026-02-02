import 'package:flutter/foundation.dart';
import 'package:meditrack/presentation/screens/base/screen_state.dart';

/// Base ViewModel
///
/// Abstract base class for all ViewModels in the application.
/// Provides common state management functionality like loading state,
/// error handling, and state notifications.
///
/// All ViewModels should extend this class to maintain consistency
/// across the application.
abstract class BaseViewModel extends ChangeNotifier {
  String? _error;

  /// Error message
  String? get error => _error;

  /// Check if there's an error
  bool get hasError => _error != null;

  void changeScreenState(ScreenState value) {
    screenState.value = value;
  }

  /// Set error message
  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  ValueNotifier<ScreenState> screenState = ValueNotifier(ScreenState.content);

  /// Execute an async operation with loading and error handling
  ///
  /// [operation] - The async operation to execute
  /// Returns the result of the operation
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    Function(dynamic error, dynamic stackError)? errorCallBack,
  }) async {
    try {
      changeScreenState(ScreenState.apiProgress);
      clearError();
      await Future.delayed(Duration(milliseconds: 500));
      final result = await operation();
      changeScreenState(ScreenState.content);
      return result;
    } catch (e, stackError) {
      setError(e.toString());
      changeScreenState(ScreenState.content);
      if (errorCallBack != null) {
        errorCallBack(e, stackError);
      }

      return null;
    } finally {}
  }


}

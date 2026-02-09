import 'dart:async';

import 'package:meditrack/log/app_logs.dart';

/// Global service to prevent double execution of the same action
class ActionThrottleService {
  // Map: actionKey → Completer (true if currently running)
  final Map<Object, Completer<void>> _runningActions = {};

  /// Execute [action] only if the same [key] is not already running
  /// Returns true if action was executed, false if ignored (duplicate)
  Future<bool> execute<T>({
    required Object key,           // Can be String, hashCode, or any object
    required Future<T> Function() action,
    bool ignoreDuplicates = true,  // Set false if you want to allow queuing
  }) async {
    final completer = _runningActions[key];

    // If already running → ignore (or handle differently)
    if (completer != null && !completer.isCompleted) {
      if (ignoreDuplicates) {
        appLog('🔒 Action ignored (duplicate): $key');
        return false;
      }
    }

    // Create new completer and run action
    final newCompleter = Completer<void>();
    _runningActions[key] = newCompleter;

    try {
      final result = await action();
      appLog('✅ Action completed: $key $result');
      return true;
    } catch (e) {
      appLog('❌ Action failed: $key | Error: $e');
      rethrow;
    } finally {
      // Always clean up
      if (_runningActions[key] == newCompleter) {
        _runningActions.remove(key);
      }
      if (!newCompleter.isCompleted) {
        newCompleter.complete();
      }
    }
  }

  /// Cancel a running action by key
  void cancel(Object key) {
    _runningActions.remove(key)?.complete();
  }

  /// Clear all
  void dispose() {
    _runningActions.clear();
  }
}


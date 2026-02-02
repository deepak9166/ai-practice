import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/vm_provider.dart';

extension SafeExecuteExtension on WidgetRef {
  /// Safe async action with automatic deduplication
  Future<bool> safeExecute({
    required Object key,  // Use hashCode, String id, or custom object
    required Future<void> Function() action,
  }) {
    return read(actionThrottleProvider).execute(
      key: key,
      action: action,
    );
  }
}
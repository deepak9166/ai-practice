import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/network/services/bio_matric_service.dart';
import '../../../../enum/bio_matric_enum.dart';

typedef Reader = T Function<T>(ProviderListenable<T> provider);

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricStatus>(
      (ref) => BiometricNotifier(ref.read),
    );

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

class BiometricNotifier extends StateNotifier<BiometricStatus> {
  BiometricNotifier(this._read) : super(BiometricStatus.idle);

  final Reader _read;

  Future<void> authenticate() async {
    final service = _read(biometricServiceProvider);

    final available = await service.isAvailable();
    if (!available) {
      state = BiometricStatus.unavailable;
      return;
    }

    state = BiometricStatus.authenticating;

    final success = await service.authenticate();
    state = success ? BiometricStatus.authenticated : BiometricStatus.failed;
  }

  void reset() {
    state = BiometricStatus.idle;
  }
}

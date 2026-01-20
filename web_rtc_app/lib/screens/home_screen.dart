import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/webrtc_viewmodel.dart';
import '../models/connection_state.dart' as models;

/// Home screen with navigation options
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webrtcState = ref.watch(webrtcViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Mobile App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'WebRTC Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan a QR code from the Chrome Extension to establish a WebRTC connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/qr-scanner');
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              if (webrtcState.connectionState.isConnected) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/connection-status');
                  },
                  child: const Text('View Connection Status'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


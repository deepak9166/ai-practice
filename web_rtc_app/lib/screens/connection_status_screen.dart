import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:clipboard/clipboard.dart';
import '../viewmodels/webrtc_viewmodel.dart';
import '../models/connection_state.dart' as models;

/// Screen showing connection status and SDP answer QR code
class ConnectionStatusScreen extends ConsumerStatefulWidget {
  const ConnectionStatusScreen({super.key});

  @override
  ConsumerState<ConnectionStatusScreen> createState() =>
      _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState
    extends ConsumerState<ConnectionStatusScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(webrtcViewModelProvider);
    final viewModel = ref.read(webrtcViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              viewModel.reconnect();
            },
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusIndicator(state.connectionState),
                    const SizedBox(height: 16),
                    Text(
                      state.connectionState.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // SDP Answer QR Code
            if (state.encodedAnswer != null) ...[
              const Text(
                'Scan this QR code with the Chrome Extension:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      QrImageView(
                        data: state.encodedAnswer!,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FlutterClipboard.copy(state.sdpAnswer ?? '');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('SDP Answer copied to clipboard'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy SDP Answer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Navigation buttons
            ElevatedButton(
              onPressed: state.connectionState.isConnected
                  ? () {
                      Navigator.of(context).pushNamed('/chat');
                    }
                  : null,
              child: const Text('Go to Chat'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: state.connectionState.isConnected
                  ? () {
                      Navigator.of(context).pushNamed('/file-transfer');
                    }
                  : null,
              child: const Text('File Transfer'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                viewModel.disconnect();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(models.ConnectionState state) {
    Color color;
    IconData icon;

    switch (state) {
      case models.ConnectionState.connected:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case models.ConnectionState.connecting:
      case models.ConnectionState.reconnecting:
        color = Colors.orange;
        icon = Icons.sync;
        break;
      case models.ConnectionState.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case models.ConnectionState.disconnected:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
    }

    return Icon(icon, size: 64, color: color);
  }
}

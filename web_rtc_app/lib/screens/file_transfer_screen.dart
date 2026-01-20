import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/file_transfer_viewmodel.dart';
import '../viewmodels/webrtc_viewmodel.dart';
import '../models/connection_state.dart' as models;
import '../services/file_transfer_service.dart';

/// Screen for file transfer over WebRTC data channel
class FileTransferScreen extends ConsumerWidget {
  const FileTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileTransferState = ref.watch(fileTransferViewModelProvider);
    final webrtcState = ref.watch(webrtcViewModelProvider);
    final fileTransferViewModel = ref.read(fileTransferViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Transfer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: webrtcState.connectionState.isConnected
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Send file section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Send File',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: webrtcState.connectionState.isConnected &&
                              !fileTransferState.isSending
                          ? () {
                              fileTransferViewModel.pickAndSendFile();
                            }
                          : null,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Select File to Send'),
                    ),
                    if (fileTransferState.isSending &&
                        fileTransferState.sendProgress != null) ...[
                      const SizedBox(height: 16),
                      _buildProgressIndicator(
                        context,
                        fileTransferState.sendProgress!,
                        'Sending',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Receive file section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Receive File',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (fileTransferState.isReceiving &&
                        fileTransferState.receiveProgress != null)
                      _buildProgressIndicator(
                        context,
                        fileTransferState.receiveProgress!,
                        'Receiving',
                      )
                    else
                      const Text(
                        'Waiting for file...',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            // Error message
            if (fileTransferState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileTransferState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        fileTransferViewModel.clearError();
                      },
                    ),
                  ],
                ),
              ),
            ],
            // Loading indicator
            if (fileTransferState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    FileTransferProgress progress,
    String label,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                progress.fileName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${progress.percentage}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.percentage / 100,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatBytes(progress.bytesTransferred)} / ${_formatBytes(progress.totalBytes)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        if (progress.isComplete) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                progress.savedPath != null
                    ? 'Saved to: ${progress.savedPath}'
                    : 'Transfer complete',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}


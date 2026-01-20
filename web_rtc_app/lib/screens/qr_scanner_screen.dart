import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../viewmodels/webrtc_viewmodel.dart';

/// Screen for scanning QR code containing SDP offer
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _textController = TextEditingController();
  bool _showManualEntry = false;
  bool isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleQRCode(String? code) {
    if (code == null) return;

    // Debug: Print QR code data info
    print('QR Code scanned - Length: ${code.length}');
    print(
      'QR Code starts with: ${code.substring(0, code.length > 50 ? 50 : code.length)}...',
    );
    print('QR Code is compressed: ${code.startsWith('z')}');

    final viewModel = ref.read(webrtcViewModelProvider.notifier);
    viewModel.processQRCode(code).then((encodedAnswer) {
      if (encodedAnswer != null && mounted) {
        // Navigate to connection status screen
        Navigator.of(context).pushReplacementNamed('/connection-status');
      } else if (mounted) {
        // Show error with more details
        final state = ref.read(webrtcViewModelProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error ?? 'Invalid QR code. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(webrtcViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showManualEntry ? Icons.qr_code_scanner : Icons.edit),
            onPressed: () {
              setState(() {
                _showManualEntry = !_showManualEntry;
              });
            },
            tooltip: _showManualEntry ? 'Switch to QR Scanner' : 'Manual Entry',
          ),
        ],
      ),
      body: _showManualEntry
          ? _buildManualEntryView(state)
          : _buildScannerView(state),
    );
  }

  Widget _buildScannerView(WebRTCState state) {
    return Stack(
      children: [
        // QR Scanner
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (isScanned) {
              return;
            }
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                if (isScanned) return;
                isScanned = true;
                print('QR Code: ${barcode.rawValue}');
                _handleQRCode(barcode.rawValue);
                break;
              }
            }
          },
        ),
        // Overlay with instructions
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Point your camera at the QR code from the Chrome Extension',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Loading indicator
        if (state.isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildManualEntryView(WebRTCState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manual Entry',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Paste the compressed code from the Chrome Extension below:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste compressed code here...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: state.isLoading
                ? null
                : () {
                    final code = _textController.text.trim();
                    if (code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter the compressed code'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    _handleQRCode(code);
                  },
            icon: const Icon(Icons.check),
            label: const Text('Process Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (state.isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

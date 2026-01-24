import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Screen for scanning QR code containing SDP offer
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
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

    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
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
      body: _showManualEntry ? _buildManualEntryView() : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
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
      ],
    );
  }

  Widget _buildManualEntryView() {
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
        ],
      ),
    );
  }
}

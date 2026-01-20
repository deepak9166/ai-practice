import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/sdp_offer.dart';

/// Service for handling QR code encoding and decoding
class QRService {
  /// Decompresses deflate-compressed data
  /// JavaScript CompressionStream 'deflate' produces raw deflate data
  Uint8List _decompressDeflate(Uint8List compressed) {
    // JavaScript CompressionStream 'deflate' uses raw deflate format (no zlib header)
    // Try ZLibCodec with raw: true first
    try {
      final codec = ZLibCodec(level: ZLibOption.defaultLevel, raw: true);
      final result = codec.decode(compressed);
      return Uint8List.fromList(result);
    } catch (e) {
      print('Raw deflate failed: $e');
      // Fallback: try with zlib wrapper (in case the format is different)
      try {
        final codec = ZLibCodec();
        final result = codec.decode(compressed);
        return Uint8List.fromList(result);
      } catch (e2) {
        print('Zlib wrapper also failed: $e2');
        // Last attempt: try adding zlib header manually
        try {
          // Raw deflate data might need zlib header (0x78 0x9C)
          final withHeader = Uint8List(compressed.length + 2);
          withHeader[0] = 0x78;
          withHeader[1] = 0x9C;
          withHeader.setRange(2, withHeader.length, compressed);
          final codec = ZLibCodec();
          final result = codec.decode(withHeader);
          return Uint8List.fromList(result);
        } catch (e3) {
          print('All decompression attempts failed. Last error: $e3');
          rethrow;
        }
      }
    }
  }

  /// Decodes Base64 encoded JSON from QR code (handles compressed data)
  /// Returns SDPOffer if valid, null otherwise
  SDPOffer? decodeQRCode(String qrData) {
    try {
      String jsonString = '';

      // Check if data is compressed (starts with 'z')
      if (qrData.startsWith('z')) {
        try {
          // Compressed data - remove 'z' prefix and decompress
          final compressedBase64 = qrData.substring(1);
          print(
            'Attempting to decompress data, base64 length: ${compressedBase64.length}',
          );

          final compressedBytes = base64Decode(compressedBase64);
          print('Compressed bytes length: ${compressedBytes.length}');

          final decompressedBytes = _decompressDeflate(compressedBytes);
          print('Decompressed bytes length: ${decompressedBytes.length}');

          jsonString = utf8.decode(decompressedBytes);
          print('Decompressed JSON string length: ${jsonString.length}');
          print(
            'JSON starts with: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}',
          );
        } catch (e, stackTrace) {
          print('Error decompressing QR data: $e');
          print('Stack trace: $stackTrace');
          // Try as uncompressed in case compression failed on extension side
          try {
            print('[DATA]  -- $jsonString');
            print('Trying uncompressed fallback...');
            final decodedBytes = base64Decode(qrData.substring(1));
            jsonString = utf8.decode(decodedBytes);
            print('Uncompressed fallback succeeded');
          } catch (e2) {
            print('Error decoding uncompressed fallback: $e2');
            return null;
          }
        }
      } else {
        // Try uncompressed first
        try {
          final decodedBytes = base64Decode(qrData);
          jsonString = utf8.decode(decodedBytes);
        } catch (e) {
          // If that fails, try as compressed (without 'z' prefix)
          try {
            final compressedBytes = base64Decode(qrData);
            final decompressedBytes = _decompressDeflate(compressedBytes);
            jsonString = utf8.decode(decompressedBytes);
          } catch (e2) {
            print(
              'Error decoding QR data (both compressed and uncompressed failed): $e2',
            );
            return null;
          }
        }
      }

      print('[DATA] 2  -- $jsonString');

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Create SDPOffer
      final offer = SDPOffer.fromJson(jsonData);

      // Validate
      if (offer.isValid()) {
        return offer;
      }

      print(
        'SDP offer validation failed: type=${offer.type}, sdp length=${offer.sdp.length}',
      );
      return null;
    } catch (e) {
      // Invalid QR code data
      print('Error decoding QR code: $e');
      return null;
    }
  }

  /// Encodes SDP answer to Base64 JSON for QR code generation
  String encodeSDPAnswer(String sdpAnswer) {
    final answerData = {
      'type': 'answer',
      'sdp': sdpAnswer,
      'meta': {'source': 'mobile_app', 'version': '1.0.0'},
    };

    final jsonString = jsonEncode(answerData);
    final encodedBytes = utf8.encode(jsonString);
    return base64Encode(encodedBytes);
  }

  /// Validates if QR data is in expected format (handles compressed data)
  bool isValidQRFormat(String qrData) {
    try {
      // Try to decode - if it succeeds, format is valid
      final offer = decodeQRCode(qrData);
      return offer != null;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/webrtc_service.dart';
import '../models/file_metadata.dart';

/// Service for handling file transfer over WebRTC data channel
class FileTransferService {
  final WebRTCService _webrtcService;
  
  // Stream controllers for file transfer progress
  final _sendProgressController = StreamController<FileTransferProgress>.broadcast();
  final _receiveProgressController = StreamController<FileTransferProgress>.broadcast();
  
  // File receiving state
  final Map<String, FileReceiveState> _receivingFiles = {};
  String? _currentReceivingFileId;
  
  // Stream subscriptions
  StreamSubscription? _binarySubscription;
  StreamSubscription? _jsonSubscription;
  
  // Constants
  static const int chunkSize = 16 * 1024; // 16KB

  FileTransferService(this._webrtcService) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to binary messages (file chunks)
    _binarySubscription = _webrtcService.binaryMessageStream.listen((binaryData) {
      if (_currentReceivingFileId != null) {
        handleFileChunk(_currentReceivingFileId!, binaryData);
      }
    });

    // Listen to JSON messages (file metadata and completion)
    _jsonSubscription = _webrtcService.jsonMessageStream.listen((jsonData) {
      final type = jsonData['type'] as String?;
      if (type == 'file_metadata') {
        final metadata = FileMetadata.fromJson(jsonData);
        handleFileMetadata(metadata);
      } else if (type == 'file_transfer_complete') {
        final fileId = jsonData['fileId'] as String;
        handleFileTransferComplete(fileId);
      }
    });
  }

  Stream<FileTransferProgress> get sendProgressStream => _sendProgressController.stream;
  Stream<FileTransferProgress> get receiveProgressStream => _receiveProgressController.stream;

  /// Sends file in chunks
  Future<void> sendFile(PlatformFile file) async {
    try {
      // Read file bytes
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception('File bytes are null');
      }

      // Create metadata
      final metadata = FileMetadata.create(
        fileName: file.name,
        fileSize: fileBytes.length,
        mimeType: file.extension ?? 'application/octet-stream',
      );

      // Send metadata first
      await _webrtcService.sendJsonData(metadata.toJson());

      // Calculate chunks
      final totalChunks = (fileBytes.length / chunkSize).ceil();

      // Send chunks
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize < fileBytes.length) 
            ? start + chunkSize 
            : fileBytes.length;
        
        final chunk = fileBytes.sublist(start, end);
        
        // Send chunk as binary
        await _webrtcService.sendBinaryData(chunk);

        // Update progress
        final progress = FileTransferProgress(
          fileId: metadata.fileId,
          fileName: metadata.fileName,
          bytesTransferred: end,
          totalBytes: fileBytes.length,
          percentage: (end / fileBytes.length * 100).round(),
        );
        _sendProgressController.add(progress);
      }

      // Send completion signal
      final complete = FileTransferComplete.create(metadata.fileId);
      await _webrtcService.sendJsonData(complete.toJson());

      // Final progress update
      _sendProgressController.add(FileTransferProgress(
        fileId: metadata.fileId,
        fileName: metadata.fileName,
        bytesTransferred: fileBytes.length,
        totalBytes: fileBytes.length,
        percentage: 100,
        isComplete: true,
      ));
    } catch (e) {
      _sendProgressController.addError(e);
      rethrow;
    }
  }

  /// Handles incoming file metadata
  void handleFileMetadata(FileMetadata metadata) {
    _currentReceivingFileId = metadata.fileId;
    _receivingFiles[metadata.fileId] = FileReceiveState(
      metadata: metadata,
      receivedBytes: <int>[],
    );
  }

  /// Handles incoming file chunk
  void handleFileChunk(String fileId, List<int> chunk) {
    final state = _receivingFiles[fileId];
    if (state == null) return;

    state.receivedBytes.addAll(chunk);

    // Update progress
    final progress = FileTransferProgress(
      fileId: fileId,
      fileName: state.metadata.fileName,
      bytesTransferred: state.receivedBytes.length,
      totalBytes: state.metadata.fileSize,
      percentage: (state.receivedBytes.length / state.metadata.fileSize * 100).round(),
    );
    _receiveProgressController.add(progress);
  }

  /// Handles file transfer completion
  Future<void> handleFileTransferComplete(String fileId) async {
    final state = _receivingFiles[fileId];
    if (state == null) return;

    try {
      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${state.metadata.fileName}';
      final file = File(filePath);
      
      await file.writeAsBytes(state.receivedBytes);

      // Final progress update
      _receiveProgressController.add(FileTransferProgress(
        fileId: fileId,
        fileName: state.metadata.fileName,
        bytesTransferred: state.metadata.fileSize,
        totalBytes: state.metadata.fileSize,
        percentage: 100,
        isComplete: true,
        savedPath: filePath,
      ));

      // Clean up
      _receivingFiles.remove(fileId);
    } catch (e) {
      _receiveProgressController.addError(e);
    }
  }

  void dispose() {
    _binarySubscription?.cancel();
    _jsonSubscription?.cancel();
    _sendProgressController.close();
    _receiveProgressController.close();
    _receivingFiles.clear();
    _currentReceivingFileId = null;
  }
}

/// Model for file transfer progress
class FileTransferProgress {
  final String fileId;
  final String fileName;
  final int bytesTransferred;
  final int totalBytes;
  final int percentage;
  final bool isComplete;
  final String? savedPath;

  FileTransferProgress({
    required this.fileId,
    required this.fileName,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.percentage,
    this.isComplete = false,
    this.savedPath,
  });
}

/// Internal state for receiving files
class FileReceiveState {
  final FileMetadata metadata;
  final List<int> receivedBytes;

  FileReceiveState({
    required this.metadata,
    required this.receivedBytes,
  });
}


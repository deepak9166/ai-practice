import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_transfer_service.dart';
import '../services/webrtc_service.dart';
import 'webrtc_viewmodel.dart';

/// Provider for FileTransferService
final fileTransferServiceProvider = Provider<FileTransferService>((ref) {
  final webrtcService = ref.watch(webrtcServiceProvider);
  final service = FileTransferService(webrtcService);
  ref.onDispose(() => service.dispose());
  return service;
});

/// ViewModel for file transfer functionality
class FileTransferViewModel extends StateNotifier<FileTransferState> {
  final FileTransferService _fileTransferService;
  final WebRTCService _webrtcService;

  FileTransferViewModel(this._fileTransferService, this._webrtcService)
      : super(FileTransferState.initial()) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to send progress
    _fileTransferService.sendProgressStream.listen((progress) {
      state = state.copyWith(
        sendProgress: progress,
        isSending: !progress.isComplete,
      );
    });

    // Listen to receive progress
    _fileTransferService.receiveProgressStream.listen((progress) {
      state = state.copyWith(
        receiveProgress: progress,
        isReceiving: !progress.isComplete,
      );
    });

    // Listen to data channel messages for file transfer
    _webrtcService.dataChannelStateStream.listen((channelState) {
      // Handle data channel state changes if needed
    });
  }

  /// Picks and sends a file
  Future<void> pickAndSendFile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await _fileTransferService.sendFile(file);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }


  /// Clears error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Resets transfer state
  void reset() {
    state = FileTransferState.initial();
  }
}

/// State class for FileTransfer ViewModel
class FileTransferState {
  final bool isLoading;
  final bool isSending;
  final bool isReceiving;
  final String? error;
  final FileTransferProgress? sendProgress;
  final FileTransferProgress? receiveProgress;

  FileTransferState({
    required this.isLoading,
    required this.isSending,
    required this.isReceiving,
    this.error,
    this.sendProgress,
    this.receiveProgress,
  });

  factory FileTransferState.initial() {
    return FileTransferState(
      isLoading: false,
      isSending: false,
      isReceiving: false,
    );
  }

  FileTransferState copyWith({
    bool? isLoading,
    bool? isSending,
    bool? isReceiving,
    String? error,
    FileTransferProgress? sendProgress,
    FileTransferProgress? receiveProgress,
  }) {
    return FileTransferState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isReceiving: isReceiving ?? this.isReceiving,
      error: error ?? this.error,
      sendProgress: sendProgress ?? this.sendProgress,
      receiveProgress: receiveProgress ?? this.receiveProgress,
    );
  }
}

/// Provider for FileTransferViewModel
final fileTransferViewModelProvider =
    StateNotifierProvider<FileTransferViewModel, FileTransferState>((ref) {
  final fileTransferService = ref.watch(fileTransferServiceProvider);
  final webrtcService = ref.watch(webrtcServiceProvider);
  return FileTransferViewModel(fileTransferService, webrtcService);
});


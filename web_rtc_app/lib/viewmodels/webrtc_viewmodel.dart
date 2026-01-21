import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/webrtc_service.dart';
import '../services/qr_service.dart';
import '../models/connection_state.dart' as models;

/// Provider for WebRTCService
final webrtcServiceProvider = Provider<WebRTCService>((ref) {
  final service = WebRTCService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for QRService
final qrServiceProvider = Provider<QRService>((ref) {
  return QRService();
});

/// ViewModel for WebRTC connection management
class WebRTCViewModel extends StateNotifier<WebRTCState> {
  final WebRTCService _webrtcService;
  final QRService _qrService;
  String? _sdpAnswer;

  WebRTCViewModel(this._webrtcService, this._qrService)
    : super(WebRTCState.initial()) {
    _setupListeners();
  }

  void _setupListeners() {
    _webrtcService.connectionStateStream.listen((connectionState) {
      print("[WEBRTC VIEWMODEL] Connection state changed: $connectionState");
      state = state.copyWith(connectionState: connectionState);
    });
  }

  /// Initializes WebRTC connection
  Future<void> initialize() async {
    try {
      print("[WEBRTC VIEWMODEL] STEP - 1");
      state = state.copyWith(isLoading: true, error: null);
      await _webrtcService.initialize();
      state = state.copyWith(isLoading: false);
      print("[WEBRTC VIEWMODEL] STEP - 2");
    } catch (e) {
      print('Error initializing WebRTC: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Processes QR code and establishes connection
  Future<String?> processQRCode(String qrData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Decode QR code
      final offer = _qrService.decodeQRCode(qrData);
      print('Offer: $offer');
      if (offer == null) {
        // Try to get more details about why it failed
        final isValid = _qrService.isValidQRFormat(qrData);
        throw Exception(
          'Invalid QR code format. -- QR data length: ${qrData.length}, isValidFormat: $isValid',
        );
      }

      // Always reinitialize to ensure clean state (as answerer - don't create data channel)
      // Close existing connection if any
      if (_webrtcService.currentState != models.ConnectionState.disconnected) {
        await _webrtcService.disconnect();
      }

      // Initialize as answerer (don't create data channel, wait for it from offerer)
      await _webrtcService.initialize(isAnswerer: true);

      // Set remote description (offer) - this must be done before creating answer
      print('Setting remote description (offer)...');
      await _webrtcService.setRemoteDescription(offer.sdp, offer.type);
      print('Remote description set successfully');

      // Create answer - peer connection should now be in 'have-remote-offer' state
      print('Creating answer...');
      final answer = await _webrtcService.createAnswer();
      print('Answer created successfully');
      _sdpAnswer = answer;

      // Encode answer for QR code
      final encodedAnswer = _qrService.encodeSDPAnswer(answer);

      state = state.copyWith(
        isLoading: false,
        sdpAnswer: answer,
        encodedAnswer: encodedAnswer,
      );

      print('Encoded answer: $encodedAnswer');

      return encodedAnswer;
    } catch (e) {
      print('Error processing QR code: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Disconnects from peer
  Future<void> disconnect() async {
    try {
      await _webrtcService.disconnect();
      state = WebRTCState.initial();
      _sdpAnswer = null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reconnects to peer
  Future<void> reconnect() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _webrtcService.reconnect();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String? get sdpAnswer => _sdpAnswer;
}

/// State class for WebRTC ViewModel
class WebRTCState {
  final bool isLoading;
  final String? error;
  final models.ConnectionState connectionState;
  final String? sdpAnswer;
  final String? encodedAnswer;

  WebRTCState({
    required this.isLoading,
    this.error,
    required this.connectionState,
    this.sdpAnswer,
    this.encodedAnswer,
  });

  factory WebRTCState.initial() {
    return WebRTCState(
      isLoading: false,
      connectionState: models.ConnectionState.disconnected,
    );
  }

  WebRTCState copyWith({
    bool? isLoading,
    String? error,
    models.ConnectionState? connectionState,
    String? sdpAnswer,
    String? encodedAnswer,
  }) {
    return WebRTCState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      connectionState: connectionState ?? this.connectionState,
      sdpAnswer: sdpAnswer ?? this.sdpAnswer,
      encodedAnswer: encodedAnswer ?? this.encodedAnswer,
    );
  }
}

/// Provider for WebRTCViewModel
final webrtcViewModelProvider =
    StateNotifierProvider<WebRTCViewModel, WebRTCState>((ref) {
      final webrtcService = ref.watch(webrtcServiceProvider);
      final qrService = ref.watch(qrServiceProvider);
      return WebRTCViewModel(webrtcService, qrService);
    });

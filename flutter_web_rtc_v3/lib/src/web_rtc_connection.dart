import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import '../service/api_service.dart';
import '../service/qr_scanner_screen.dart';
import 'adm_sample.dart';
import 'capture_frame_sample.dart';
import 'data_packet_cryptor_sample.dart';
import 'device_enumeration_sample.dart';
import 'get_display_media_sample.dart';
import 'get_user_media_sample.dart';
import 'loopback_data_channel_sample.dart';
import 'loopback_sample_unified_tracks.dart';
import 'route_item.dart';

// ─── Chat message model ────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isMine;
  final DateTime time;
  final bool isFile;
  final String? fileName;
  final int? fileSize;
  final Uint8List? fileBytes;

  _ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
    this.isFile = false,
    this.fileName,
    this.fileSize,
    this.fileBytes,
  });
}

// ─── Main page ─────────────────────────────────────────────────────────────

class WebRTCManualSDPPage extends StatefulWidget {
  const WebRTCManualSDPPage({super.key});

  @override
  State<WebRTCManualSDPPage> createState() => _WebRTCManualSDPPageState();
}

class _WebRTCManualSDPPageState extends State<WebRTCManualSDPPage> {
  // WebRTC core
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // ICE servers – 5 Google STUN servers for broad reachability.
  // For cross-network (different WiFi / mobile data) you must also add a
  // TURN server: {'urls':'turn:YOUR_SERVER','username':'u','credential':'p'}
  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ],
  };

  // UI state
  String _status = 'Disconnected';
  bool _isConnected = false;
  bool _isBusy = false;
  final ValueNotifier<String> _qrId = ValueNotifier('');

  // Signaling
  final TextEditingController _sdpController = TextEditingController();

  // Chat
  final List<_ChatMessage> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Incoming file state
  String? _incomingFileName;
  int? _incomingFileSize;
  final List<int> _incomingFileBytes = [];

  // Video call state – camera is OFF by default, enabled on demand
  bool _cameraEnabled = false;
  bool _isVideoCallActive = false;
  bool _isRenegotiating = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _createPeerConnection();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.getTracks().forEach((t) => t.stop());
    _peerConnection?.close();
    _sdpController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _qrId.dispose();
    super.dispose();
  }

  // ── Peer connection setup ──────────────────────────────────────────────────

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_config);

    _peerConnection!.onTrack = (event) {
      if (mounted && event.streams.isNotEmpty) {
        setState(() => _remoteRenderer.srcObject = event.streams[0]);
      }
    };

    // Device B receives the data channel that Device A created
    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };

    _peerConnection!.onIceConnectionState = (state) {
      if (!mounted) return;
      setState(() {
        switch (state) {
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            _status = 'Connected ✓';
            _isConnected = true;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            _status = 'Disconnected';
            _isConnected = false;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            _status = 'Connection failed – check network';
            _isConnected = false;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
            _status = 'Connecting…';
            break;
          default:
            break;
        }
      });
    };
  }

  // ── ICE gathering wait ────────────────────────────────────────────────────
  //
  // After setLocalDescription, ICE candidates are gathered asynchronously.
  // We must wait until gathering is complete so that the SDP we upload
  // contains all "a=candidate:" lines. Without them the remote peer has no
  // network path to connect to.

  Future<String> _waitForIceComplete() async {
    final completer = Completer<String>();

    // Bug fix: TWO guards are required.
    //
    // Guard 1 (top of function): fast-exit if already done.
    // Guard 2 (after await): multiple callbacks can all pass Guard 1 and
    // then race to call completer.complete() after the await. Without Guard 2
    // the second caller throws "Bad state: Future already completed".
    Future<void> finish() async {
      if (completer.isCompleted) return; // Guard 1
      final desc = await _peerConnection!.getLocalDescription();
      if (completer.isCompleted) return; // Guard 2 – prevents StateError
      if (desc != null) {
        completer.complete(jsonEncode(desc.toMap()));
      }
    }

    // Primary signal: gathering state reaches "complete"
    _peerConnection!.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        finish();
      }
    };

    // Secondary signal: some platforms fire onIceCandidate with an empty
    // candidate string to indicate gathering is done
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate == null || candidate.candidate!.isEmpty) {
        finish();
      }
    };

    // Handle the case where gathering already completed before we registered
    // the callbacks above (can happen on fast LAN connections)
    if (_peerConnection!.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      finish();
    }

    // Timeout fallback – 15 seconds is generous for a LAN/WiFi environment
    Future.delayed(const Duration(seconds: 15), finish);

    return completer.future;
  }

  // ── Media ─────────────────────────────────────────────────────────────────

  Future<void> _openUserMedia() async {
    if (_localStream != null) return; // already open
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localRenderer.srcObject = stream;
    _localStream = stream;
    for (var track in stream.getTracks()) {
      await _peerConnection!.addTrack(track, stream);
    }
  }

  // ── Signaling – Device A ──────────────────────────────────────────────────

  Future<void> _createOffer() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _status = 'Setting up connection…';
    });
    try {
      // Camera stays OFF during signaling – user enables it via "Start Video Call"
      // after the data channel is established.

      // Data channel must be created BEFORE the offer so that the SDP
      // includes the "m=application" SCTP section.
      final init = RTCDataChannelInit()..ordered = true;
      _dataChannel = await _peerConnection!.createDataChannel('chat', init);
      _setupDataChannel();

      setState(() => _status = 'Creating offer…');
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      setState(() => _status = 'Gathering ICE candidates…');
      // Wait until all candidates are embedded in the SDP
      final sdpJson = await _waitForIceComplete();
      _sdpController.text = sdpJson;

      setState(() => _status = 'Uploading offer…');
      final id = await ApiService.createQrCode(sdpJson);
      _qrId.value = id;

      setState(() {
        _status = 'Show QR to Device B, then scan Device B\'s QR';
        _isBusy = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isBusy = false;
      });
    }
  }

  // ── SDP pre-check ─────────────────────────────────────────────────────────
  //
  // Validates the text in _sdpController before any WebRTC call is made.
  // Returns a human-readable error string, or null when the SDP is valid.

  String? _validateSdp(String expectedType) {
    final raw = _sdpController.text.trim();

    // 1. Empty field
    if (raw.isEmpty) {
      return 'SDP field is empty. Scan the QR from the other device first.';
    }

    // 2. Must be valid JSON
    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return 'SDP must be a JSON object, got: ${decoded.runtimeType}';
      }
      map = decoded;
    } on FormatException catch (e) {
      // Point to exact position in the JSON where parsing failed
      final pos = e.offset != null ? ' (position ${e.offset})' : '';
      return 'Invalid JSON$pos: ${e.message}';
    }

    // 3. Must have both "type" and "sdp" keys
    if (!map.containsKey('type')) {
      return 'Missing "type" field in SDP JSON.';
    }
    if (!map.containsKey('sdp')) {
      return 'Missing "sdp" field in SDP JSON.';
    }

    // 4. Type must be a non-empty string
    final type = map['type'];
    if (type is! String || type.isEmpty) {
      return '"type" must be a non-empty string, got: $type';
    }

    // 5. Type must match what this step expects ('offer' or 'answer')
    if (type != expectedType) {
      return 'Expected SDP type "$expectedType" but got "$type".\n'
          'Make sure you are pasting the correct SDP for this step.';
    }

    // 6. "sdp" must be a non-empty string
    final sdp = map['sdp'];
    if (sdp is! String || sdp.isEmpty) {
      return '"sdp" must be a non-empty string.';
    }

    // 7. Quick sanity-check that it looks like an SDP body
    if (!sdp.contains('v=0')) {
      return '"sdp" does not look like a valid SDP – missing "v=0" line.';
    }

    return null; // all good
  }

  /// Shows a red SnackBar with the validation error and resets busy state.
  void _showSdpError(String error) {
    setState(() => _isBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[700],
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ── Signaling – Device B ──────────────────────────────────────────────────

  Future<void> _setOfferAndCreateAnswer() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _status = 'Checking SDP…';
    });

    final error = _validateSdp('offer');
    if (error != null) {
      _showSdpError(error);
      setState(() => _status = 'SDP error – see banner');
      return;
    }

    setState(() => _status = 'Setting remote offer…');
    try {
      final offerMap = jsonDecode(_sdpController.text) as Map<String, dynamic>;

      // onDataChannel must be registered (done in _createPeerConnection)
      // before setRemoteDescription so it fires during SDP processing.
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offerMap['sdp'], offerMap['type']),
      );

      // Camera stays OFF – user enables it after connecting.
      setState(() => _status = 'Creating answer…');
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      setState(() => _status = 'Gathering ICE candidates…');
      final sdpJson = await _waitForIceComplete();
      _sdpController.text = sdpJson;

      setState(() => _status = 'Uploading answer…');
      final id = await ApiService.createQrCode(sdpJson);
      _qrId.value = id;

      setState(() {
        _status = 'Show QR to Device A so it can set the answer';
        _isBusy = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isBusy = false;
      });
    }
  }

  // ── Signaling – Device A sets answer ─────────────────────────────────────

  Future<void> _setAnswer() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _status = 'Checking SDP…';
    });

    final error = _validateSdp('answer');
    if (error != null) {
      _showSdpError(error);
      setState(() => _status = 'SDP error – see banner');
      return;
    }

    setState(() => _status = 'Setting remote answer…');
    try {
      final answerMap = jsonDecode(_sdpController.text) as Map<String, dynamic>;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answerMap['sdp'], answerMap['type']),
      );
      setState(() {
        _status = 'Connecting…';
        _isBusy = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isBusy = false;
      });
    }
  }

  // ── QR scanner helper ─────────────────────────────────────────────────────

  void _callGetQrCode(String code) {
    ApiService.getQrCode(code).then((value) {
      _sdpController.text = value;
      _qrId.value = ''; // hide own QR once peer QR is scanned
    });
  }

  // ── Data channel ──────────────────────────────────────────────────────────

  void _setupDataChannel() {
    if (_dataChannel == null) return;
    _dataChannel!.onDataChannelState = (state) {
      if (!mounted) return;
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        setState(() {
          _isConnected = true;
          _status = 'Connected ✓';
        });
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        setState(() {
          _isConnected = false;
          _status = 'Data channel closed';
        });
      }
    };
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        _handleIncomingBinary(message.binary);
      } else {
        _handleIncomingText(message.text);
      }
    };
  }

  void _handleIncomingText(String text) {
    if (!mounted) return;
    try {
      final data = jsonDecode(text) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'chat') {
        setState(
          () => _messages.add(
            _ChatMessage(
              text: data['text'] as String,
              isMine: false,
              time: DateTime.fromMillisecondsSinceEpoch(data['time'] as int),
            ),
          ),
        );
        _scrollToBottom();
      } else if (type == 'file_start') {
        _incomingFileName = data['name'] as String;
        _incomingFileSize = data['size'] as int;
        _incomingFileBytes.clear();
      } else if (type == 'file_end') {
        final bytes = Uint8List.fromList(_incomingFileBytes);
        final name = _incomingFileName ?? 'received_file';
        setState(
          () => _messages.add(
            _ChatMessage(
              text: 'Received: $name',
              isMine: false,
              time: DateTime.now(),
              isFile: true,
              fileName: name,
              fileSize: _incomingFileSize,
              fileBytes: bytes,
            ),
          ),
        );
        _incomingFileName = null;
        _incomingFileSize = null;
        _incomingFileBytes.clear();
        _scrollToBottom();
      } else if (type == 'renegotiate_offer') {
        // Remote started a video call – open camera and answer
        _handleRenegotiateOffer(data['sdp'] as Map<String, dynamic>);
      } else if (type == 'renegotiate_answer') {
        // Remote accepted the video call
        _handleRenegotiateAnswer(data['sdp'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Plain-text fallback
      setState(
        () => _messages.add(
          _ChatMessage(text: text, isMine: false, time: DateTime.now()),
        ),
      );
      _scrollToBottom();
    }
  }

  void _handleIncomingBinary(Uint8List bytes) {
    _incomingFileBytes.addAll(bytes);
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty ||
        _dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen)
      return;

    final payload = jsonEncode({
      'type': 'chat',
      'text': text,
      'time': DateTime.now().millisecondsSinceEpoch,
    });
    await _dataChannel!.send(RTCDataChannelMessage(payload));

    setState(
      () => _messages.add(
        _ChatMessage(text: text, isMine: true, time: DateTime.now()),
      ),
    );
    _chatController.clear();
    _scrollToBottom();
  }

  // ── File transfer ─────────────────────────────────────────────────────────

  Future<void> _sendFile() async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen)
      return;

    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final fileName = file.name;
    final fileBytes = file.bytes!;
    const chunkSize = 16384; // 16 KB per chunk

    // 1. Send metadata
    await _dataChannel!.send(
      RTCDataChannelMessage(
        jsonEncode({
          'type': 'file_start',
          'name': fileName,
          'size': fileBytes.length,
        }),
      ),
    );

    // 2. Send binary chunks
    for (var i = 0; i < fileBytes.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, fileBytes.length);
      await _dataChannel!.send(
        RTCDataChannelMessage.fromBinary(fileBytes.sublist(i, end)),
      );
    }

    // 3. Signal end
    await _dataChannel!.send(
      RTCDataChannelMessage(jsonEncode({'type': 'file_end', 'name': fileName})),
    );

    setState(
      () => _messages.add(
        _ChatMessage(
          text: 'Sent: $fileName',
          isMine: true,
          time: DateTime.now(),
          isFile: true,
          fileName: fileName,
          fileSize: fileBytes.length,
        ),
      ),
    );
    _scrollToBottom();
  }

  Future<void> _saveReceivedFile(_ChatMessage msg) async {
    if (msg.fileBytes == null) return;
    try {
      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${msg.fileName}';
      await File(path).writeAsBytes(msg.fileBytes!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved to $path')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Video call (optional, post-connection via data-channel renegotiation) ──

  /// Toggle camera on/off. First call opens the camera and triggers a
  /// renegotiation offer so the remote peer gets the video stream too.
  Future<void> _toggleVideoCall() async {
    if (_isRenegotiating) return;

    if (_isVideoCallActive) {
      // ── Stop video call ──────────────────────────────────────────────────
      _localStream?.getTracks().forEach((t) => t.stop());
      _localStream = null;
      if (mounted) {
        _localRenderer.srcObject = null;
        setState(() {
          _cameraEnabled = false;
          _isVideoCallActive = false;
          _status = 'Connected ✓ (data only)';
        });
      }
    } else {
      // ── Start video call ─────────────────────────────────────────────────
      setState(() => _isRenegotiating = true);
      try {
        await _openUserMedia();
        setState(() {
          _cameraEnabled = true;
          _isVideoCallActive = true;
        });
        await _initiateRenegotiation();
      } catch (e) {
        setState(() {
          _cameraEnabled = false;
          _isVideoCallActive = false;
          _status = 'Camera error: $e';
        });
      } finally {
        if (mounted) setState(() => _isRenegotiating = false);
      }
    }
  }

  /// Device A sends a new offer (with audio+video tracks) via the data channel.
  Future<void> _initiateRenegotiation() async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) return;

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    setState(() => _status = 'Renegotiating for video…');
    final sdpJson = await _waitForIceComplete();

    await _dataChannel!.send(RTCDataChannelMessage(jsonEncode({
      'type': 'renegotiate_offer',
      'sdp': jsonDecode(sdpJson),
    })));
    setState(() => _status = 'Video call active ✓');
  }

  /// Device B: received a renegotiation offer → open camera, create answer,
  /// send back via data channel.
  Future<void> _handleRenegotiateOffer(Map<String, dynamic> offerData) async {
    if (_isRenegotiating) return;
    setState(() { _isRenegotiating = true; _status = 'Incoming video call…'; });
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          offerData['sdp'] as String,
          offerData['type'] as String,
        ),
      );

      if (!_cameraEnabled) {
        await _openUserMedia();
        setState(() { _cameraEnabled = true; _isVideoCallActive = true; });
      }

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      final sdpJson = await _waitForIceComplete();

      if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
        await _dataChannel!.send(RTCDataChannelMessage(jsonEncode({
          'type': 'renegotiate_answer',
          'sdp': jsonDecode(sdpJson),
        })));
      }
      if (mounted) setState(() => _status = 'Video call active ✓');
    } catch (e) {
      if (mounted) setState(() => _status = 'Video renegotiation error: $e');
    } finally {
      if (mounted) setState(() => _isRenegotiating = false);
    }
  }

  /// Device A: received the answer from Device B → apply it to complete
  /// the video renegotiation.
  Future<void> _handleRenegotiateAnswer(Map<String, dynamic> answerData) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          answerData['sdp'] as String,
          answerData['type'] as String,
        ),
      );
      if (mounted) setState(() => _status = 'Video call active ✓');
    } catch (e) {
      if (mounted) setState(() => _status = 'Video answer error: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC P2P'),
        actions: [
          IconButton(
            tooltip: 'Scan QR',
            onPressed: () async {
              final code = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => QRScannerScreen()),
              );
              if (code != null) _callGetQrCode(code);
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            color: _isConnected ? Colors.green[100] : Colors.orange[50],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              _status,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _isConnected ? Colors.green[900] : Colors.orange[900],
              ),
            ),
          ),

          // Video views – only shown when camera is active
          if (_cameraEnabled)
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        RTCVideoView(_localRenderer, mirror: true),
                        const Positioned(
                          left: 4,
                          bottom: 4,
                          child: Text('You',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  shadows: [Shadow(blurRadius: 2)])),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        RTCVideoView(_remoteRenderer),
                        const Positioned(
                          left: 4,
                          bottom: 4,
                          child: Text('Remote',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  shadows: [Shadow(blurRadius: 2)])),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Signaling panel (shown until connected) ──────────────────
          if (!_isConnected) ...[
            // QR code for the current side to share
            ValueListenableBuilder<String>(
              valueListenable: _qrId,
              builder: (_, id, __) {
                if (id.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 6),
                    QrImageView(data: id, version: QrVersions.auto, size: 160),
                    Text('ID: $id', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),

            // SDP paste field (populated by QR scan or manual paste)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: TextField(
                controller: _sdpController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'SDP (paste or scan QR)',
                  hintText: 'Scan the QR code from the other device',
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _createOffer,
                    icon: const Icon(Icons.call_made, size: 16),
                    label: const Text('Create Offer\n(Device A)'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _setOfferAndCreateAnswer,
                    icon: const Icon(Icons.call_received, size: 16),
                    label: const Text('Set Offer &\nAnswer (Device B)'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _setAnswer,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Set Answer\n(Device A)'),
                  ),
                ],
              ),
            ),

            if (_isBusy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: LinearProgressIndicator(),
              ),
          ],

          // ── Chat panel (shown when connected) ────────────────────────
          if (_isConnected) ...[
            // Video call toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRenegotiating ? null : _toggleVideoCall,
                  icon: Icon(
                    _isVideoCallActive ? Icons.videocam_off : Icons.videocam,
                    size: 18,
                  ),
                  label: Text(
                    _isRenegotiating
                        ? 'Negotiating…'
                        : _isVideoCallActive
                            ? 'Stop Video Call'
                            : 'Start Video Call',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVideoCallActive
                        ? Colors.red[100]
                        : Colors.green[100],
                    foregroundColor: _isVideoCallActive
                        ? Colors.red[900]
                        : Colors.green[900],
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  return Align(
                    alignment: msg.isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMine ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: msg.isFile
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.insert_drive_file, size: 18),
                                const SizedBox(width: 6),
                                Flexible(child: Text(msg.fileName ?? 'File')),
                                if (!msg.isMine && msg.fileBytes != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _saveReceivedFile(msg),
                                    child: const Icon(
                                      Icons.download,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Text(msg.text),
                    ),
                  );
                },
              ),
            ),

            // Chat input row
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sendFile,
                    icon: const Icon(Icons.attach_file),
                    tooltip: 'Send file',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Type a message…',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendChatMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  IconButton(
                    onPressed: _sendChatMessage,
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RTCConnectionPage2 extends StatefulWidget {
  const RTCConnectionPage2({super.key});

  @override
  State<RTCConnectionPage2> createState() => _RTCConnectionPage2State();
}

class _RTCConnectionPage2State extends State<RTCConnectionPage2> {
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> offerConstraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    'optional': [],
  };

  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> initPeerConnection() async {
    _peerConnection = await createPeerConnection(configuration);

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      // SEND candidate to other device via signaling
      print('ICE Candidate: ${candidate.toMap()}');
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      remoteRenderer.srcObject = event.streams[0];
    };
  }

  Future<void> openUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection.addTrack(track, _localStream!);
    }
  }

  Future<Map<String, dynamic>> createOffer() async {
    RTCSessionDescription offer = await _peerConnection.createOffer(
      offerConstraints,
    );

    await _peerConnection.setLocalDescription(offer);

    // SEND THIS to Device B
    return offer.toMap();
  }

  Future<Map<String, dynamic>> receiveOfferCreateAnswer(
    Map<String, dynamic> offer,
  ) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    RTCSessionDescription answer = await _peerConnection.createAnswer();

    await _peerConnection.setLocalDescription(answer);

    // SEND answer back to Device A
    return answer.toMap();
  }

  Future<void> receiveAnswer(Map<String, dynamic> answer) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(answer['sdp'], answer['type']),
    );
  }

  Future<void> addIceCandidate(Map<String, dynamic> candidate) async {
    await _peerConnection.addCandidate(
      RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: RTCVideoView(localRenderer)),
          Expanded(child: RTCVideoView(remoteRenderer)),
        ],
      ),
    );
  }
}

class RTCConnectionPage extends StatefulWidget {
  const RTCConnectionPage({super.key});

  @override
  State<RTCConnectionPage> createState() => _RTCConnectionPageState();
}

class _RTCConnectionPageState extends State<RTCConnectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RTC Connection')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                initialize();
              },
              child: Text("Connect to RTC d"),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  Future<void> initialize({bool isAnswerer = false}) async {
    try {
      _updateState(ConnectionState.waiting);

      _peerConnection = await createPeerConnection(_iceServers);

      print("STEP 1");

      // Set up ICE candidate handler
      // Note: This will be overridden in createAnswer() to collect candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
          print('ICE candidate: ${candidate.candidate}');
        } else {
          print('ICE candidate gathering complete (null candidate)');
        }
      };

      print("STEP 2");

      // Set up ICE connection state change handler (more reliable for connection status)
      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        print('ICE connection state changed: $state');
        print('Current signaling state: ${_peerConnection!.signalingState}');
        print('ICE gathering state: ${_peerConnection!.iceGatheringState}');

        switch (state) {
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            print('✅ ICE connection established!');
            _updateState(ConnectionState.active);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            print('⚠️ ICE connection disconnected');
            _updateState(ConnectionState.none);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            print('❌ ICE connection FAILED!');
            print('This usually means:');
            print('1. No valid ICE candidates in SDP');
            print('2. Network connectivity issues');
            print('3. Firewall blocking connection');
            print('4. Devices cannot reach each other');
            _updateState(ConnectionState.none);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
            print('🔄 ICE connection checking...');
            _updateState(ConnectionState.waiting);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateNew:
            print('🆕 ICE connection new');
            _updateState(ConnectionState.waiting);
            break;
          default:
            print('Unknown ICE connection state: $state');
            break;
        }
      };

      // Set up connection state change handler (backup)
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        print('Connection state changed: $state');
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            print('✅ Peer connection connected!');
            // Check data channel state when connection is established
            if (_dataChannel != null) {
              print(
                'Data channel state when connection established: ${_dataChannel!.state}',
              );
              if (_dataChannel!.state ==
                  RTCDataChannelState.RTCDataChannelOpen) {
                _updateState(ConnectionState.done);
              } else {
                // Connection is up but data channel not open yet - wait a bit
                print(
                  'Connection established but data channel not open yet, waiting...',
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_dataChannel != null &&
                      _dataChannel!.state ==
                          RTCDataChannelState.RTCDataChannelOpen) {
                    print('✅ Data channel opened after connection');
                    _updateState(ConnectionState.done);
                  }
                });
              }
            } else {
              // No data channel yet, but connection is established
              _updateState(ConnectionState.done);
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            _updateState(ConnectionState.none);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            _updateState(ConnectionState.none);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            _updateState(ConnectionState.waiting);
            break;
          default:
            break;
        }
      };

      // Set up data channel handler (for when receiving offer)
      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        print('Data channel received: ${channel.label}');
        _dataChannel = channel;
        _setupDataChannelHandlers();
      };

      // Only create data channel if we're the offerer
      if (!isAnswerer) {
        print('STEP 4');
        await _createDataChannel();
      }
    } catch (e) {
      print('Error initializing WebRTC: $e');
      _updateState(ConnectionState.none);
      rethrow;
    }
  }

  /// Creates reliable and ordered data channel
  Future<void> _createDataChannel() async {
    print('STEP 5');
    if (_peerConnection == null) return;
    print('STEP 6');

    final dataChannelInit = RTCDataChannelInit()..ordered = true;

    _dataChannel = await _peerConnection!.createDataChannel(
      'data_channel',
      dataChannelInit,
    );

    print("STEp 8");

    _setupDataChannelHandlers();
  }

  void _updateState(ConnectionState status) {
    print('updateState $status');
    _currentState = status;
    setState(() {});
  }

  ConnectionState _currentState = ConnectionState.none;

  /// Sets up data channel event handlers
  void _setupDataChannelHandlers() {
    print('STEP 10');
    if (_dataChannel == null) return;
    print('STEP 11');
    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      print('Data channel state changed: $state');

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('STEP 11.1');
        print('✅ Data channel opened - connection established!');
        _updateState(ConnectionState.active);
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        print('STEP 11.2');
        print('Data channel closed');
        _updateState(ConnectionState.none);
      } else if (state == RTCDataChannelState.RTCDataChannelConnecting) {
        print('STEP 11.3');
        print('Data channel connecting...');
        _updateState(ConnectionState.waiting);
      } else {
        print('STEP 11.4');
      }
    };
    print('STEP 12');
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      print('📨 Data channel message received');
      _handleDataChannelMessage(message);

      // If we receive a message, the connection is definitely established
      if (_currentState != ConnectionState.active) {
        print('✅ Connection confirmed by receiving message');
        _updateState(ConnectionState.active);
      }
    };

    print('STEP 13');
  }

  /// Handles incoming messages from data channel
  void _handleDataChannelMessage(RTCDataChannelMessage message) {
    print('message $message');
    // try {
    //   if (message.isBinary) {
    //     // Handle binary data (file chunks)
    //     final binaryData = message.binary;
    //     _binaryMessageController.add(binaryData);
    //     return;
    //   }

    //   // Handle text messages
    //   final jsonData = message.text;
    //   if (jsonData.isEmpty) return;
    //   final decoded = jsonDecode(jsonData) as Map<String, dynamic>;

    //   // Emit JSON message for file transfer service
    //   _jsonMessageController.add(decoded);

    //   // Handle chat messages
    //   if (decoded['type'] == 'chat') {
    //     final chatMessage = ChatMessage.fromJson(decoded);
    //     _messageController.add(chatMessage);
    //   }
    // } catch (e) {
    //   // Invalid message format - try to handle as plain text chat
    //   try {
    //     final chatMessage = ChatMessage(
    //       type: 'chat',
    //       message: message.text,
    //       timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    //       sender: 'peer',
    //     );
    //     _messageController.add(chatMessage);
    //   } catch (e2) {
    //     // Ignore if still fails
    //   }
    // }
  }

  /// Sets remote description from SDP offer
  Future<void> setRemoteDescription(String sdp, String type) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    if (type != 'offer') {
      throw Exception('Expected offer type, got: $type');
    }

    print('Setting remote description: type=$type, sdp length=${sdp.length}');
    final description = RTCSessionDescription(sdp, type);

    try {
      await _peerConnection!.setRemoteDescription(description);
      print('Remote description set successfully');
    } catch (e) {
      print('Error setting remote description: $e');
      print('Peer connection state: ${_peerConnection!.signalingState}');
      rethrow;
    }
  }
}

class RTCNavigation extends StatefulWidget {
  @override
  _RTCNavigationState createState() => _RTCNavigationState();
}

class _RTCNavigationState extends State<RTCNavigation> {
  late List<RouteItem> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  ListBody _buildRow(context, item) {
    return ListBody(
      children: <Widget>[
        ListTile(
          title: Text(item.title),
          onTap: () => item.push(context),
          trailing: Icon(Icons.arrow_right),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter-WebRTC example')),
        body: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return _buildRow(context, items[i]);
          },
        ),
      ),
    );
  }

  void _initItems() {
    items = <RouteItem>[
      RouteItem(
        title: 'GetUserMedia',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => GetUserMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Device Enumeration',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DeviceEnumerationSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'GetDisplayMedia',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => GetDisplayMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'LoopBack Sample (Unified Tracks)',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => LoopBackSampleUnifiedTracks(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'DataChannelLoopBackSample',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DataChannelLoopBackSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Capture Frame',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CaptureFrameSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'ADM Sample',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => AdmSample()),
          );
        },
      ),
      RouteItem(
        title: 'Data Packet Cryptor Sample',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DataPacketCryptorSample(),
            ),
          );
        },
      ),
    ];
  }
}

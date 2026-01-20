import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/connection_state.dart' as models;
import '../models/chat_message.dart';

/// Service for managing WebRTC peer connection and data channel
class WebRTCService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  // Stream controllers for state updates
  final _connectionStateController =
      StreamController<models.ConnectionState>.broadcast();
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _dataChannelStateController =
      StreamController<RTCDataChannelState>.broadcast();
  final _binaryMessageController = StreamController<List<int>>.broadcast();
  final _jsonMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<models.ConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<RTCDataChannelState> get dataChannelStateStream =>
      _dataChannelStateController.stream;
  Stream<List<int>> get binaryMessageStream => _binaryMessageController.stream;
  Stream<Map<String, dynamic>> get jsonMessageStream =>
      _jsonMessageController.stream;

  models.ConnectionState _currentState = models.ConnectionState.disconnected;
  models.ConnectionState get currentState => _currentState;

  bool get isConnected => _currentState == models.ConnectionState.connected;
  RTCDataChannel? get dataChannel => _dataChannel;

  /// STUN server configuration (matches extension)
  ///
  /// CRITICAL: Android/Flutter WebRTC REQUIRES at least one STUN server
  /// to generate ICE candidates, even for local network connections.
  /// Without STUN servers, NO candidates are generated and connection WILL FAIL.
  ///
  /// The STUN server is only used for candidate discovery, not for actual
  /// data relay (that would require TURN). For same-network connections,
  /// STUN helps discover local IP addresses.
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  /// Creates RTCPeerConnection
  /// [isAnswerer] - if true, don't create data channel (wait for it from offerer)
  Future<void> initialize({bool isAnswerer = false}) async {
    try {
      _updateState(models.ConnectionState.connecting);

      _peerConnection = await createPeerConnection(_iceServers);

      // Set up ICE candidate handler
      // Note: This will be overridden in createAnswer() to collect candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
          print('ICE candidate: ${candidate.candidate}');
        } else {
          print('ICE candidate gathering complete (null candidate)');
        }
      };

      // Set up ICE connection state change handler (more reliable for connection status)
      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        print('ICE connection state changed: $state');
        print('Current signaling state: ${_peerConnection!.signalingState}');
        print('ICE gathering state: ${_peerConnection!.iceGatheringState}');

        switch (state) {
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            print('✅ ICE connection established!');
            _updateState(models.ConnectionState.connected);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            print('⚠️ ICE connection disconnected');
            _updateState(models.ConnectionState.disconnected);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            print('❌ ICE connection FAILED!');
            print('This usually means:');
            print('1. No valid ICE candidates in SDP');
            print('2. Network connectivity issues');
            print('3. Firewall blocking connection');
            print('4. Devices cannot reach each other');
            _updateState(models.ConnectionState.failed);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
            print('🔄 ICE connection checking...');
            _updateState(models.ConnectionState.connecting);
            break;
          case RTCIceConnectionState.RTCIceConnectionStateNew:
            print('🆕 ICE connection new');
            _updateState(models.ConnectionState.connecting);
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
                _updateState(models.ConnectionState.connected);
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
                    _updateState(models.ConnectionState.connected);
                  }
                });
              }
            } else {
              // No data channel yet, but connection is established
              _updateState(models.ConnectionState.connected);
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            _updateState(models.ConnectionState.disconnected);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            _updateState(models.ConnectionState.failed);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            _updateState(models.ConnectionState.connecting);
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
        await _createDataChannel();
      }
    } catch (e) {
      print('Error initializing WebRTC: $e');
      _updateState(models.ConnectionState.failed);
      rethrow;
    }
  }

  /// Creates reliable and ordered data channel
  Future<void> _createDataChannel() async {
    if (_peerConnection == null) return;

    final dataChannelInit = RTCDataChannelInit()..ordered = true;

    _dataChannel = await _peerConnection!.createDataChannel(
      'data_channel',
      dataChannelInit,
    );

    _setupDataChannelHandlers();
  }

  /// Sets up data channel event handlers
  void _setupDataChannelHandlers() {
    if (_dataChannel == null) return;

    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      print('Data channel state changed: $state');
      _dataChannelStateController.add(state);

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('✅ Data channel opened - connection established!');
        _updateState(models.ConnectionState.connected);

        // Send a test message to verify connection works
        _sendConnectionTestMessage();
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        print('Data channel closed');
        _updateState(models.ConnectionState.disconnected);
      } else if (state == RTCDataChannelState.RTCDataChannelConnecting) {
        print('Data channel connecting...');
        _updateState(models.ConnectionState.connecting);
      }
    };

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      print('📨 Data channel message received');
      _handleDataChannelMessage(message);

      // If we receive a message, the connection is definitely established
      if (_currentState != models.ConnectionState.connected) {
        print('✅ Connection confirmed by receiving message');
        _updateState(models.ConnectionState.connected);
      }
    };

    // Poll data channel state as backup (in case events don't fire)
    _pollDataChannelState();
  }

  /// Polls data channel state to detect when it opens
  void _pollDataChannelState() {
    if (_dataChannel == null) return;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_dataChannel == null) {
        timer.cancel();
        return;
      }

      final state = _dataChannel!.state;
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (_currentState != models.ConnectionState.connected) {
          print('✅ Data channel is open (detected via polling)');
          _updateState(models.ConnectionState.connected);
          _sendConnectionTestMessage();
        }
        timer.cancel();
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        if (_currentState != models.ConnectionState.disconnected) {
          print('Data channel is closed (detected via polling)');
          _updateState(models.ConnectionState.disconnected);
        }
        timer.cancel();
      }
    });
  }

  /// Sends a test message to verify connection is working
  void _sendConnectionTestMessage() {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      return;
    }

    try {
      // Send a simple test message to verify connection
      final testMessage = jsonEncode({
        'type': 'connection_test',
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'message': 'Connection established',
      });
      _dataChannel!.send(RTCDataChannelMessage(testMessage));
      print('✅ Sent connection test message');
    } catch (e) {
      print('Error sending test message: $e');
    }
  }

  /// Handles incoming messages from data channel
  void _handleDataChannelMessage(RTCDataChannelMessage message) {
    try {
      if (message.isBinary) {
        // Handle binary data (file chunks)
        final binaryData = message.binary;
        _binaryMessageController.add(binaryData);
        return;
      }

      // Handle text messages
      final jsonData = message.text;
      if (jsonData.isEmpty) return;
      final decoded = jsonDecode(jsonData) as Map<String, dynamic>;

      // Emit JSON message for file transfer service
      _jsonMessageController.add(decoded);

      // Handle chat messages
      if (decoded['type'] == 'chat') {
        final chatMessage = ChatMessage.fromJson(decoded);
        _messageController.add(chatMessage);
      }
    } catch (e) {
      // Invalid message format - try to handle as plain text chat
      try {
        final chatMessage = ChatMessage(
          type: 'chat',
          message: message.text,
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          sender: 'peer',
        );
        _messageController.add(chatMessage);
      } catch (e2) {
        // Ignore if still fails
      }
    }
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

  // Store collected ICE candidates
  final List<RTCIceCandidate> _collectedIceCandidates = [];

  /// Creates answer and sets local description
  /// Waits for ICE gathering to complete and includes all ICE candidates
  Future<String> createAnswer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    // Check signaling state - must be in 'have-remote-offer' state
    print('Current signaling state: ${_peerConnection!.signalingState}');
    if (_peerConnection!.signalingState !=
        RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
      throw Exception(
        'Cannot create answer. Current state: ${_peerConnection!.signalingState}. '
        'Expected: RTCSignalingStateHaveRemoteOffer. '
        'Make sure remote description (offer) is set first.',
      );
    }

    print('Creating answer...');
    try {
      // Clear previously collected candidates
      _collectedIceCandidates.clear();

      // Create answer
      final answer = await _peerConnection!.createAnswer();

      // Set up ICE candidate collection BEFORE setting local description
      final completer = Completer<void>();
      final originalIceCandidateHandler = _peerConnection!.onIceCandidate;

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
          print('ICE candidate collected:');
          print('  - candidate: ${candidate.candidate}');
          print('  - sdpMid: ${candidate.sdpMid}');
          print('  - sdpMLineIndex: ${candidate.sdpMLineIndex}');
          _collectedIceCandidates.add(candidate);
        } else {
          // null candidate means gathering is complete
          print('ICE candidate gathering complete (null candidate received)');
          print(
            'Total candidates collected: ${_collectedIceCandidates.length}',
          );
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
        // Also call original handler if it exists
        originalIceCandidateHandler?.call(candidate);
      };

      // Set local description - this starts ICE gathering
      await _peerConnection!.setLocalDescription(answer);
      print(
        'Answer created and local description set, waiting for ICE gathering...',
      );
      print('ICE gathering state: ${_peerConnection!.iceGatheringState}');

      // Wait for ICE gathering to complete
      // Without STUN servers, we only get host candidates which gather quickly
      await _waitForIceGathering();

      // Also wait for null candidate (gathering complete signal)
      // Give more time for host candidates to be generated
      try {
        await completer.future.timeout(const Duration(seconds: 3));
      } catch (e) {
        print('Timeout waiting for null candidate, proceeding anyway');
      }

      // Give a small delay to ensure all host candidates are collected
      // (host candidates are generated quickly but we want to be sure)
      if (_collectedIceCandidates.isEmpty) {
        print('No candidates collected yet, waiting a bit more...');
        // Wait longer for host candidates - they should appear quickly but let's be sure
        await Future.delayed(const Duration(milliseconds: 1000));

        // Check again after delay
        if (_collectedIceCandidates.isEmpty) {
          print('⚠️ Still no candidates after waiting. This might indicate:');
          print('  1. Network interface issues');
          print('  2. WebRTC not generating host candidates');
          print('  3. Permission issues');
          print(
            '  4. Android/Flutter WebRTC may require STUN servers for candidate generation',
          );
          print('');
          print('⚠️ CRITICAL: Without candidates, the connection WILL FAIL!');
          print(
            '   Consider adding at least one STUN server to iceServers configuration.',
          );
        }
      } else {
        print(
          '✅ Collected ${_collectedIceCandidates.length} candidates before delay',
        );
      }

      // Get the local description SDP
      final localDescription = await _peerConnection!.getLocalDescription();
      if (localDescription == null || localDescription.sdp == null) {
        throw Exception('Local description is null after ICE gathering');
      }

      var sdp = localDescription.sdp!;
      print('ICE gathering complete, answer SDP length: ${sdp.length}');

      // Check if SDP contains ICE candidates
      var candidateCount = sdp.split('a=candidate:').length - 1;
      print('Answer SDP contains $candidateCount ICE candidates from SDP');
      print(
        'Collected ${_collectedIceCandidates.length} ICE candidates via callback',
      );

      // If SDP doesn't have candidates but we collected them, add them manually
      if (candidateCount == 0 && _collectedIceCandidates.isNotEmpty) {
        print('SDP has no candidates, adding collected candidates manually...');
        sdp = _addIceCandidatesToSdp(sdp, _collectedIceCandidates);
        candidateCount = sdp.split('a=candidate:').length - 1;
        print('After adding candidates: $candidateCount candidates in SDP');
      }

      if (candidateCount == 0) {
        print('WARNING: Answer SDP has no ICE candidates!');
        print(
          'Without STUN servers, only host candidates (local IPs) are generated.',
        );
        print('This will work if both devices are on the same local network.');
        print('Collected candidates: ${_collectedIceCandidates.length}');
        if (_collectedIceCandidates.isNotEmpty) {
          print(
            'Candidates were collected but not added to SDP - this is a bug!',
          );
        } else {
          print('No candidates were collected - check network connectivity.');
        }
      } else {
        print('✅ Answer SDP has $candidateCount ICE candidates - should work!');
      }

      // Debug: Print first few lines of SDP to verify format
      final sdpLines = sdp.split('\r\n');
      print('SDP preview (first 20 lines):');
      for (int i = 0; i < sdpLines.length && i < 20; i++) {
        if (sdpLines[i].isNotEmpty) {
          print('  ${sdpLines[i]}');
        }
      }

      // Debug: Print candidate lines
      final candidateLines = sdpLines
          .where((line) => line.startsWith('a=candidate:'))
          .toList();
      print('Candidate lines in SDP (${candidateLines.length}):');
      for (final line in candidateLines) {
        // Print first 120 chars of each candidate line
        final preview = line.length > 120
            ? '${line.substring(0, 120)}...'
            : line;
        print('  $preview');
      }

      // Validate SDP structure
      final hasVersion = sdpLines.any((line) => line.startsWith('v='));
      final hasOrigin = sdpLines.any((line) => line.startsWith('o='));
      final hasSession = sdpLines.any((line) => line.startsWith('s='));
      final hasTime = sdpLines.any((line) => line.startsWith('t='));
      final mediaCount = sdpLines.where((line) => line.startsWith('m=')).length;

      print('SDP validation:');
      print('  v= (version): ${hasVersion ? "✅" : "❌"}');
      print('  o= (origin): ${hasOrigin ? "✅" : "❌"}');
      print('  s= (session): ${hasSession ? "✅" : "❌"}');
      print('  t= (time): ${hasTime ? "✅" : "❌"}');
      print('  m= (media): $mediaCount sections');
      print('  a=candidate: $candidateCount candidates');

      if (!hasVersion || !hasOrigin || !hasSession || !hasTime) {
        print('⚠️ WARNING: SDP structure is invalid!');
      }

      if (mediaCount == 0) {
        print('❌ ERROR: No media sections in SDP!');
      }

      // Final summary before returning
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('ANSWER SDP SUMMARY:');
      print('  Total length: ${sdp.length} bytes');
      print('  Media sections: $mediaCount');
      print('  ICE candidates in SDP: $candidateCount');
      print(
        '  Candidates collected via callback: ${_collectedIceCandidates.length}',
      );
      if (candidateCount > 0) {
        print('  ✅ SDP has candidates - connection should work');
      } else {
        print('  ❌ SDP has NO candidates - connection will FAIL');
        print('  ⚠️  This is the root cause of connection failure!');
      }
      print('═══════════════════════════════════════════════════════════');
      print('');

      return sdp;
    } catch (e) {
      print('Error creating answer: $e');
      print('Signaling state: ${_peerConnection!.signalingState}');
      rethrow;
    }
  }

  /// Adds ICE candidates to SDP string
  /// Associates candidates with their respective media sections using sdpMLineIndex
  String _addIceCandidatesToSdp(String sdp, List<RTCIceCandidate> candidates) {
    if (candidates.isEmpty) return sdp;

    final lines = sdp.split('\r\n');
    final mediaSections = <int>[];

    // Find all media section indices
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('m=')) {
        mediaSections.add(i);
      }
    }

    if (mediaSections.isEmpty) {
      print('WARNING: No media sections found in SDP!');
      return sdp;
    }

    print('Found ${mediaSections.length} media sections in SDP');

    // Group candidates by media section (sdpMLineIndex)
    final candidatesByMedia = <int, List<String>>{};

    for (final candidate in candidates) {
      if (candidate.candidate == null || candidate.candidate!.isEmpty) {
        continue;
      }

      // Get the media section index (default to 0 if not specified)
      final mediaIndex = candidate.sdpMLineIndex ?? 0;

      // Ensure media index is valid
      if (mediaIndex < 0 || mediaIndex >= mediaSections.length) {
        print('WARNING: Invalid media index $mediaIndex, using 0');
        final validIndex = 0;
        if (!candidatesByMedia.containsKey(validIndex)) {
          candidatesByMedia[validIndex] = <String>[];
        }
      } else {
        if (!candidatesByMedia.containsKey(mediaIndex)) {
          candidatesByMedia[mediaIndex] = <String>[];
        }
      }

      // Format the candidate string
      // In flutter_webrtc, candidate.candidate contains the full candidate attribute value
      // Format should be: "candidate <foundation> <component> <protocol> <priority> <ip> <port> typ <type> ..."
      String candidateStr = candidate.candidate!.trim();

      print('  Raw candidate string: $candidateStr');

      // Remove "a=" prefix if present
      if (candidateStr.startsWith('a=')) {
        candidateStr = candidateStr.substring(2).trim();
      }

      // Remove "candidate " prefix if present (some formats include it)
      if (candidateStr.startsWith('candidate ')) {
        candidateStr = candidateStr.substring(10).trim();
      }

      // The candidate string should now be in format: "<foundation> <component> <protocol> ..."
      // We need to ensure it starts with "candidate:" for SDP format
      if (!candidateStr.startsWith('candidate:')) {
        // If it doesn't start with "candidate:", add it
        candidateStr = 'candidate:$candidateStr';
      }

      // Add proper SDP format: a=candidate:...
      final candidateLine = 'a=$candidateStr';

      // Validate candidate line format
      if (!candidateLine.startsWith('a=candidate:')) {
        print(
          '  ERROR: Invalid candidate format! Expected "a=candidate:...", got: $candidateLine',
        );
        continue; // Skip invalid candidates
      }
      final validIndex = (mediaIndex >= 0 && mediaIndex < mediaSections.length)
          ? mediaIndex
          : 0;
      candidatesByMedia[validIndex]!.add(candidateLine);

      print(
        'Adding candidate for media $validIndex: ${candidateLine.substring(0, candidateLine.length > 100 ? 100 : candidateLine.length)}...',
      );
    }

    if (candidatesByMedia.isEmpty) {
      print('No valid candidate lines to add');
      return sdp;
    }

    // Build new SDP with candidates added after their respective media sections
    final newLines = <String>[];
    int currentMediaIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      newLines.add(lines[i]);

      // If this is a media section, add candidates for this media section
      if (lines[i].startsWith('m=')) {
        // Find which media section this is
        if (currentMediaIndex < mediaSections.length &&
            candidatesByMedia.containsKey(currentMediaIndex)) {
          // Add candidates for this specific media section
          for (final candidateLine in candidatesByMedia[currentMediaIndex]!) {
            newLines.add(candidateLine);
          }
          print(
            'Added ${candidatesByMedia[currentMediaIndex]!.length} candidates for media section $currentMediaIndex',
          );
        }
        currentMediaIndex++;
      }
    }

    final result = newLines.join('\r\n');
    final totalCandidates = result.split('a=candidate:').length - 1;
    print(
      'SDP updated: ${result.length} bytes, $totalCandidates total candidates',
    );
    return result;
  }

  /// Waits for ICE gathering to complete
  Future<void> _waitForIceGathering() async {
    if (_peerConnection == null) return;

    // Check if already complete
    final initialState = await _peerConnection!.getIceGatheringState();
    if (initialState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      print('ICE gathering already complete');
      return;
    }

    // Wait for ICE gathering to complete (with timeout)
    final completer = Completer<void>();
    Timer? timeoutTimer;
    Timer? pollTimer;

    // Set up timeout
    timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        print('ICE gathering timeout, proceeding with available candidates');
        completer.complete();
      }
    });

    // Listen for ICE gathering state changes
    _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        if (!completer.isCompleted) {
          print('ICE gathering complete');
          completer.complete();
        }
      }
    };

    // Also poll as backup (in case events don't fire)
    pollTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (completer.isCompleted) {
        timer.cancel();
        return;
      }

      _peerConnection!.getIceGatheringState().then((state) {
        if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
          if (!completer.isCompleted) {
            print('ICE gathering complete (polling)');
            completer.complete();
          }
          timer.cancel();
        }
      });
    });

    await completer.future;
    timeoutTimer.cancel();
    pollTimer.cancel();
  }

  /// Sends message over data channel
  Future<void> sendMessage(ChatMessage message) async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw Exception('Data channel not open');
    }

    final jsonString = jsonEncode(message.toJson());
    _dataChannel!.send(RTCDataChannelMessage(jsonString));
  }

  /// Sends binary data over data channel
  Future<void> sendBinaryData(List<int> data) async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw Exception('Data channel not open');
    }

    _dataChannel!.send(
      RTCDataChannelMessage.fromBinary(Uint8List.fromList(data)),
    );
  }

  /// Sends JSON data over data channel
  Future<void> sendJsonData(Map<String, dynamic> data) async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw Exception('Data channel not open');
    }

    final jsonString = jsonEncode(data);
    _dataChannel!.send(RTCDataChannelMessage(jsonString));
  }

  /// Updates connection state and notifies listeners
  void _updateState(models.ConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionStateController.add(newState);
    }
  }

  /// Closes peer connection and cleans up
  Future<void> disconnect() async {
    print('Disconnecting WebRTC...');
    try {
      await _dataChannel?.close();
    } catch (e) {
      print('Error closing data channel: $e');
    }

    try {
      await _peerConnection?.close();
    } catch (e) {
      print('Error closing peer connection: $e');
    }

    _dataChannel = null;
    _peerConnection = null;
    _updateState(models.ConnectionState.disconnected);
    print('WebRTC disconnected');
  }

  /// Reconnects by reinitializing
  Future<void> reconnect() async {
    await disconnect();
    await initialize();
  }

  /// Disposes all resources
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _messageController.close();
    _dataChannelStateController.close();
    _binaryMessageController.close();
    _jsonMessageController.close();
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

class WebRTCService {
  RTCPeerConnection? pc;
  RTCDataChannel? dataChannel;
  final Signaling signaling;

  late String peerId;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // Callbacks for UI updates
  Function(String message)? onMessageReceived;
  Function(String status)? onConnectionStatusChanged;
  Function(bool isConnected)? onDataChannelStateChanged;
  Function(String fileName, Uint8List fileData)? onFileReceived;

  WebRTCService(this.signaling);

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> createPeer({required bool isCaller}) async {
    pc = await createPeerConnection({
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ],
    });

    pc!.onIceCandidate = (c) {
      // ICE candidates are included in SDP when gathering completes
      // No need to send separately for direct P2P
    };

    pc!.onTrack = (e) {
      remoteRenderer.srcObject = e.streams.first;
      onConnectionStatusChanged?.call("Media stream received");
    };

    pc!.onConnectionState = (state) {
      onConnectionStatusChanged?.call("Connection: $state");
    };

    pc!.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        onConnectionStatusChanged?.call("WebRTC connected!");
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        onConnectionStatusChanged?.call(
          "Connection failed - Tap Reset to try again",
        );
        onDataChannelStateChanged?.call(false);
      } else if (state ==
          RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        onConnectionStatusChanged?.call("Connection disconnected");
        onDataChannelStateChanged?.call(false);
      }
    };

    if (isCaller) {
      dataChannel = await pc!.createDataChannel("data", RTCDataChannelInit());
      _setupDataChannel();
    }

    pc!.onDataChannel = (c) {
      dataChannel = c;
      _setupDataChannel();
    };
  }

  // File receiving state
  String? _receivingFileName;
  int? _receivingFileSize;
  final List<Uint8List> _receivingFileChunks = [];

  void _setupDataChannel() {
    dataChannel!.onMessage = (msg) {
      // Check if it's a file marker
      if (msg.text.isNotEmpty) {
        final text = msg.text;
        if (text.startsWith('FILE_START:')) {
          // File start marker: FILE_START:filename:size
          final parts = text.split(':');
          if (parts.length >= 3) {
            _receivingFileName = parts[1];
            _receivingFileSize = int.tryParse(parts[2]);
            _receivingFileChunks.clear();
            print(
              "Receiving file: $_receivingFileName ($_receivingFileSize bytes)",
            );
            onConnectionStatusChanged?.call(
              "Receiving file: $_receivingFileName",
            );
          }
          return;
        } else if (text.startsWith('FILE_END:')) {
          // File end marker: FILE_END:filename
          if (_receivingFileName != null && _receivingFileChunks.isNotEmpty) {
            // Combine all chunks
            final totalSize = _receivingFileChunks.fold<int>(
              0,
              (sum, chunk) => sum + chunk.length,
            );
            final fileData = Uint8List(totalSize);
            int offset = 0;
            for (final chunk in _receivingFileChunks) {
              fileData.setRange(offset, offset + chunk.length, chunk);
              offset += chunk.length;
            }
            onFileReceived?.call(_receivingFileName!, fileData);
            onConnectionStatusChanged?.call(
              "File received: $_receivingFileName",
            );
            _receivingFileName = null;
            _receivingFileSize = null;
            _receivingFileChunks.clear();
          }
          return;
        }
      }

      // Handle text messages or file chunks
      if (_receivingFileName != null) {
        // We're receiving a file, check for chunk marker
        if (msg.text.isNotEmpty && msg.text.startsWith('FILE_CHUNK:')) {
          final base64Chunk = msg.text.substring('FILE_CHUNK:'.length);
          try {
            final chunk = base64Decode(base64Chunk);
            _receivingFileChunks.add(chunk);
          } catch (e) {
            print("Error decoding file chunk: $e");
          }
        }
      } else {
        // Regular text message - check if it's a file chunk marker
        if (msg.text.isNotEmpty) {
          if (msg.text.startsWith('FILE_CHUNK:')) {
            // This shouldn't happen if we're not receiving a file, but handle it
            print("Received file chunk but not expecting file");
          } else {
            final messageText = msg.text;
            print("Peer: $messageText");
            onMessageReceived?.call(messageText);
          }
        }
      }
    };

    dataChannel!.onDataChannelState = (state) {
      final isOpen = state == RTCDataChannelState.RTCDataChannelOpen;
      onDataChannelStateChanged?.call(isOpen);
      if (isOpen) {
        onConnectionStatusChanged?.call("P2P Connected ✅");
      } else {
        onConnectionStatusChanged?.call("Disconnected");
      }
    };

    // Check initial state
    if (dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      onDataChannelStateChanged?.call(true);
      onConnectionStatusChanged?.call("P2P Connected ✅");
    }
  }

  // Handle SDP from QR code
  Future<void> handleOfferFromQR(String sdp, String type) async {
    await createPeer(isCaller: false);
    await pc!.setRemoteDescription(RTCSessionDescription(sdp, type));
    final answer = await pc!.createAnswer();
    await pc!.setLocalDescription(answer);

    // Notify UI to show answer QR code
    onConnectionStatusChanged?.call("Answer created - Show QR code");
  }

  Future<void> handleAnswerFromQR(String sdp, String type) async {
    if (pc == null) {
      onConnectionStatusChanged?.call("Error: No peer connection");
      return;
    }
    await pc!.setRemoteDescription(RTCSessionDescription(sdp, type));
    onConnectionStatusChanged?.call(
      "Answer received - Connection establishing",
    );
  }

  // Get offer for QR code
  Future<Map<String, dynamic>> createOfferForQR() async {
    await createPeer(isCaller: true);
    final offer = await pc!.createOffer();
    await pc!.setLocalDescription(offer);

    // Wait for ICE gathering to complete
    await _waitForIceGathering();

    // Get updated SDP with all candidates
    final updatedOffer = await pc!.createOffer();
    await pc!.setLocalDescription(updatedOffer);

    return {"sdp": updatedOffer.sdp, "type": updatedOffer.type};
  }

  // Get answer for QR code
  Future<Map<String, dynamic>> createAnswerForQR() async {
    if (pc == null) {
      throw Exception("No peer connection");
    }
    final answer = await pc!.createAnswer();
    await pc!.setLocalDescription(answer);

    // Wait for ICE gathering to complete
    await _waitForIceGathering();

    // Get updated SDP with all candidates
    final updatedAnswer = await pc!.createAnswer();
    await pc!.setLocalDescription(updatedAnswer);

    return {"sdp": updatedAnswer.sdp, "type": updatedAnswer.type};
  }

  Future<void> _waitForIceGathering() async {
    // Wait for ICE gathering to complete (max 10 seconds)
    int attempts = 0;
    while (pc!.iceGatheringState !=
            RTCIceGatheringState.RTCIceGatheringStateComplete &&
        attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  // Legacy method for compatibility (no-op now)
  Future<void> handleSignal(Map<String, dynamic> data) async {
    // No-op - we use QR codes now
  }

  Future<void> startCall() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": true,
    });
    localRenderer.srcObject = stream;
    stream.getTracks().forEach((t) => pc!.addTrack(t, stream));
  }

  void sendMessage(String msg) {
    if (dataChannel != null &&
        dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      dataChannel!.send(RTCDataChannelMessage(msg));
    } else {
      print("Data channel not open. Cannot send message.");
      onConnectionStatusChanged?.call("Cannot send: Data channel not open");
    }
  }

  Future<void> sendFile(Uint8List fileData, String fileName) async {
    if (dataChannel == null ||
        dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      print("Data channel not open. Cannot send file.");
      onConnectionStatusChanged?.call("Cannot send: Data channel not open");
      return;
    }

    const chunkSize = 16000; // 16KB chunks
    int offset = 0;

    // Send file name first
    dataChannel!.send(
      RTCDataChannelMessage('FILE_START:$fileName:${fileData.length}'),
    );

    // Send file in chunks (using base64 encoding for reliability)
    while (offset < fileData.length) {
      final end = (offset + chunkSize < fileData.length)
          ? offset + chunkSize
          : fileData.length;
      final chunk = fileData.sublist(offset, end);
      // Encode chunk as base64 for reliable transmission
      final base64Chunk = base64Encode(chunk);
      dataChannel!.send(RTCDataChannelMessage('FILE_CHUNK:$base64Chunk'));
      offset = end;
    }

    // Send file end marker
    dataChannel!.send(RTCDataChannelMessage('FILE_END:$fileName'));
    print("File sent: $fileName");
  }

  Future<void> reset() async {
    print("Resetting WebRTC connection...");

    // Close data channel
    if (dataChannel != null) {
      try {
        await dataChannel!.close();
      } catch (e) {
        print("Error closing data channel: $e");
      }
      dataChannel = null;
    }

    // Close peer connection
    if (pc != null) {
      try {
        await pc!.close();
      } catch (e) {
        print("Error closing peer connection: $e");
      }
      pc = null;
    }

    // Reset file receiving state
    _receivingFileName = null;
    _receivingFileSize = null;
    _receivingFileChunks.clear();

    // Reset peer ID
    peerId = "";

    // Notify UI
    onDataChannelStateChanged?.call(false);
    onConnectionStatusChanged?.call(
      "Connection reset - Ready for new connection",
    );

    print("WebRTC connection reset complete");
  }

  Future<void> reconnect({required String newPeerId}) async {
    print("Reconnecting with peer: $newPeerId");

    // Reset existing connection
    await reset();

    // Set new peer ID
    peerId = newPeerId;

    // Create new peer connection as caller
    await createPeer(isCaller: true);

    // Create offer for QR code
    try {
      await createOfferForQR();
      onConnectionStatusChanged?.call(
        "Reconnection offer ready - Show QR code",
      );
    } catch (error) {
      print("Error creating reconnection offer: $error");
      onConnectionStatusChanged?.call("Reconnection failed: $error");
    }
  }

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    pc?.close();
    dataChannel?.close();
  }
}

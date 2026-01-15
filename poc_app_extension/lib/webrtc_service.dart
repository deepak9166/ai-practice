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
      signaling.send(to: peerId, type: "candidate", payload: c.toMap());
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
        onConnectionStatusChanged?.call("Connection failed");
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

  Future<void> handleSignal(Map<String, dynamic> data) async {
    if (data["type"] == "offer") {
      peerId = data["from"];
      await createPeer(isCaller: false);
      await pc!.setRemoteDescription(
        RTCSessionDescription(data["payload"]["sdp"], data["payload"]["type"]),
      );
      final answer = await pc!.createAnswer();
      await pc!.setLocalDescription(answer);
      signaling.send(to: peerId, type: "answer", payload: answer.toMap());
    }

    if (data["type"] == "answer") {
      await pc!.setRemoteDescription(
        RTCSessionDescription(data["payload"]["sdp"], data["payload"]["type"]),
      );
    }

    if (data["type"] == "candidate" && pc != null) {
      await pc!.addCandidate(
        RTCIceCandidate(
          data["payload"]["candidate"],
          data["payload"]["sdpMid"],
          data["payload"]["sdpMLineIndex"],
        ),
      );
    }
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

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    pc?.close();
  }
}

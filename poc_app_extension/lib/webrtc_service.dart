import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

class WebRTCService {
  RTCPeerConnection? pc;
  RTCDataChannel? dataChannel;
  final Signaling signaling;

  late String peerId;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  WebRTCService(this.signaling);

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> createPeer({required bool isCaller}) async {
    pc = await createPeerConnection({
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"}
      ]
    });

    pc!.onIceCandidate = (c) {
      signaling.send(
        to: peerId,
        type: "candidate",
        payload: c.toMap(),
      );
    };

    pc!.onTrack = (e) {
      remoteRenderer.srcObject = e.streams.first;
    };

    if (isCaller) {
      dataChannel = await pc!.createDataChannel(
        "data",
        RTCDataChannelInit(),
      );
      _setupDataChannel();
    }

    pc!.onDataChannel = (c) {
      dataChannel = c;
      _setupDataChannel();
    };
  }

  void _setupDataChannel() {
    dataChannel!.onMessage = (msg) {
      print("Peer: ${msg.text}");
    };
  }

  Future<void> handleSignal(Map<String, dynamic> data) async {
    if (data["type"] == "offer") {
      peerId = data["from"];
      await createPeer(isCaller: false);
      await pc!.setRemoteDescription(
        RTCSessionDescription(
          data["payload"]["sdp"],
          data["payload"]["type"],
        ),
      );
      final answer = await pc!.createAnswer();
      await pc!.setLocalDescription(answer);
      signaling.send(to: peerId, type: "answer", payload: answer.toMap());
    }

    if (data["type"] == "answer") {
      await pc!.setRemoteDescription(
        RTCSessionDescription(
          data["payload"]["sdp"],
          data["payload"]["type"],
        ),
      );
    }

    if (data["type"] == "candidate") {
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
    dataChannel?.send(RTCDataChannelMessage(msg));
  }

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    pc?.close();
  }
}

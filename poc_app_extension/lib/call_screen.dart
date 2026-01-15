import 'package:flutter/material.dart';
import 'signaling.dart';
import 'webrtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late Signaling signaling;
  late WebRTCService rtc;

  final myIdCtrl = TextEditingController();
  final peerIdCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    signaling = Signaling("ws://localhost:3000");
    rtc = WebRTCService(signaling);
    rtc.init();

    signaling.onMessage = rtc.handleSignal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter ↔ Extension P2P")),
      body: Column(
        children: [
          TextField(controller: myIdCtrl, decoration: const InputDecoration(labelText: "My ID")),
          TextField(controller: peerIdCtrl, decoration: const InputDecoration(labelText: "Peer ID")),
          ElevatedButton(
            onPressed: () async {
              rtc.peerId = peerIdCtrl.text;
              signaling.connect(myIdCtrl.text);
              await rtc.createPeer(isCaller: true);
              final offer = await rtc.pc!.createOffer();
              await rtc.pc!.setLocalDescription(offer);
              signaling.send(to: rtc.peerId, type: "offer", payload: offer.toMap());
            },
            child: const Text("Connect"),
          ),
          // Row(
          //   children: [
          //     Expanded(child: RTCVideoView(rtc.localRenderer)),
          //     Expanded(child: RTCVideoView(rtc.remoteRenderer)),
          //   ],
          // ),
          TextField(controller: msgCtrl),
          ElevatedButton(
            onPressed: () => rtc.sendMessage(msgCtrl.text),
            child: const Text("Send Message"),
          ),
          ElevatedButton(
            onPressed: () => rtc.startCall(),
            child: const Text("Start Call"),
          ),
        ],
      ),
    );
  }
}

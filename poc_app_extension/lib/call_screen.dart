import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'signaling.dart';
import 'webrtc_service.dart';

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
  final ScrollController _scrollController = ScrollController();

  // Chat messages list
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  String _connectionStatus = "Not connected";

  // Configure signaling server URL
  // For same machine: "ws://localhost:3000"
  // For mobile on same network: "ws://YOUR_COMPUTER_IP:3000" (e.g., "ws://192.168.1.100:3000")
  // For remote server: "ws://your-server.com:3000"
  final String signalingUrl =
      "ws://192.168.1.1:3000"; // TODO: Change to your computer's IP for mobile

  @override
  void initState() {
    super.initState();
    signaling = Signaling(signalingUrl);
    rtc = WebRTCService(signaling);
    rtc.init();

    signaling.onMessage = rtc.handleSignal;

    // Setup callbacks
    rtc.onMessageReceived = (message) {
      setState(() {
        _messages.add(
          ChatMessage(text: message, isSent: false, timestamp: DateTime.now()),
        );
      });
      _scrollToBottom();
    };

    rtc.onConnectionStatusChanged = (status) {
      setState(() {
        _connectionStatus = status;
      });
    };

    rtc.onDataChannelStateChanged = (isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    };

    rtc.onFileReceived = (fileName, fileData) {
      // Show file received notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("File received: $fileName (${fileData.length} bytes)"),
          action: SnackBarAction(
            label: "Save",
            onPressed: () {
              // TODO: Implement file saving
              // You can use path_provider and file writing here
            },
          ),
        ),
      );
      // Add a message to chat showing file was received
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "📎 File received: $fileName (${(fileData.length / 1024).toStringAsFixed(1)} KB)",
            isSent: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    };
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (msgCtrl.text.trim().isEmpty || !_isConnected) return;

    final message = msgCtrl.text.trim();
    rtc.sendMessage(message);

    setState(() {
      _messages.add(
        ChatMessage(text: message, isSent: true, timestamp: DateTime.now()),
      );
    });

    msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    myIdCtrl.dispose();
    peerIdCtrl.dispose();
    msgCtrl.dispose();
    rtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter ↔ Extension P2P"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _connectionStatus,
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Connection Setup Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: myIdCtrl,
                  decoration: const InputDecoration(
                    labelText: "My ID",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: peerIdCtrl,
                  decoration: const InputDecoration(
                    labelText: "Peer ID",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isConnected
                            ? null
                            : () async {
                                if (myIdCtrl.text.isEmpty ||
                                    peerIdCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter both User ID and Peer ID",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _connectionStatus = "Connecting...";
                                });
                                rtc.peerId = peerIdCtrl.text;
                                signaling.connect(myIdCtrl.text);
                                await rtc.createPeer(isCaller: true);
                                final offer = await rtc.pc!.createOffer();
                                await rtc.pc!.setLocalDescription(offer);
                                signaling.send(
                                  to: rtc.peerId,
                                  type: "offer",
                                  payload: offer.toMap(),
                                );
                              },
                        icon: const Icon(Icons.link),
                        label: const Text("Connect"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isConnected
                          ? () async {
                              await rtc.startCall();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Starting call..."),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.videocam),
                      tooltip: "Start Call",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green[50],
                      ),
                    ),
                    IconButton(
                      onPressed: _isConnected
                          ? () async {
                              final result = await FilePicker.platform
                                  .pickFiles();
                              if (result != null &&
                                  result.files.single.path != null) {
                                final file = File(result.files.single.path!);
                                final fileData = await file.readAsBytes();
                                await rtc.sendFile(
                                  fileData,
                                  result.files.single.name,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Sending file: ${result.files.single.name}",
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.attach_file),
                      tooltip: "Send File",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat Section
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Messages List
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isConnected
                                      ? "Start chatting..."
                                      : "Connect to start chatting",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                  ),

                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: msgCtrl,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              enabled: _isConnected,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isConnected ? _sendMessage : null,
                            icon: const Icon(Icons.send),
                            color: Colors.blue,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isSent ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isSent ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: message.isSent ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isSent;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isSent,
    required this.timestamp,
  });
}

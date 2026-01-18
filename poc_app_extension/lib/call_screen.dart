import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poc_app_extension/peer_service.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  PeerService? peerService; // For peer ID connections

  final myIdCtrl = TextEditingController();
  final peerIdCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat messages list
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  String _connectionStatus = "Not connected";
  String? _myPeerId; // For displaying our peer ID
  bool _usePeerService = false; // Toggle between PeerService and WebRTCService

  // QR Code state
  String? _offerQRData;
  String? _answerQRData;
  bool _showOfferQR = false;
  bool _showAnswerQR = false;
  bool _showScanner = false;

  @override
  void initState() {
    super.initState();
    signaling = Signaling();
    rtc = WebRTCService(signaling);
    rtc.init();

    // Initialize PeerService for peer ID connections
    peerService = PeerService();
    peerService!.onMessageReceived = (message) {
      setState(() {
        _messages.add(
          ChatMessage(text: message, isSent: false, timestamp: DateTime.now()),
        );
      });
      _scrollToBottom();
    };
    peerService!.onConnectionStatusChanged = (status) {
      setState(() {
        _connectionStatus = status;
      });
    };
    peerService!.onConnectionStateChanged = (isConnected) {
      setState(() {
        _isConnected = isConnected;
        _usePeerService = isConnected;
      });
    };

    // Auto-initialize peer service
    _initPeerService();

    // Setup callbacks for WebRTCService (fallback)
    rtc.onMessageReceived = (message) {
      if (!_usePeerService) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: message,
              isSent: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    };

    rtc.onConnectionStatusChanged = (status) {
      if (!_usePeerService) {
        setState(() {
          _connectionStatus = status;
          // Check if connection failed
          if (status.contains("failed") || status.contains("disconnected")) {
            _isConnected = false;
          }
        });
      }
    };

    rtc.onDataChannelStateChanged = (isConnected) {
      if (!_usePeerService) {
        setState(() {
          _isConnected = isConnected;
        });
      }
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

    // Use PeerService if connected via peer ID, otherwise use WebRTCService
    if (_usePeerService && peerService != null) {
      peerService!.sendMessage(message);
    } else {
      rtc.sendMessage(message);
    }

    setState(() {
      _messages.add(
        ChatMessage(text: message, isSent: true, timestamp: DateTime.now()),
      );
    });

    msgCtrl.clear();
    _scrollToBottom();
  }

  Future<void> _initPeerService() async {
    try {
      final customId = myIdCtrl.text.trim().isEmpty
          ? null
          : myIdCtrl.text.trim();
      final peerId = await peerService!.init(customId: customId);
      setState(() {
        _myPeerId = peerId;
      });
    } catch (e) {
      print("PeerService initialization failed: $e");
      // Continue with manual SDP method as fallback
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    myIdCtrl.dispose();
    peerIdCtrl.dispose();
    msgCtrl.dispose();
    rtc.dispose();
    peerService?.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Flutter ↔ Extension P2P"),
  //       bottom: PreferredSize(
  //         preferredSize: const Size.fromHeight(30),
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: 10,
  //                 height: 10,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: _isConnected ? Colors.green : Colors.red,
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   _connectionStatus,
  //                   style: TextStyle(
  //                     color: _isConnected ? Colors.green : Colors.grey,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     body: Column(
  //       children: [
  //         // Connection Setup Section
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           color: Colors.grey[100],
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: myIdCtrl,
  //                 decoration: const InputDecoration(
  //                   labelText: "My ID",
  //                   border: OutlineInputBorder(),
  //                   isDense: true,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               TextField(
  //                 controller: peerIdCtrl,
  //                 decoration: const InputDecoration(
  //                   labelText: "Peer ID",
  //                   border: OutlineInputBorder(),
  //                   isDense: true,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: ElevatedButton.icon(
  //                       onPressed: _isConnected
  //                           ? null
  //                           : () async {
  //                               if (myIdCtrl.text.isEmpty ||
  //                                   peerIdCtrl.text.isEmpty) {
  //                                 ScaffoldMessenger.of(context).showSnackBar(
  //                                   const SnackBar(
  //                                     content: Text(
  //                                       "Please enter both User ID and Peer ID",
  //                                     ),
  //                                   ),
  //                                 );
  //                                 return;
  //                               }
  //                               setState(() {
  //                                 _connectionStatus = "Creating offer...";
  //                               });
  //                               try {
  //                                 final offer = await rtc.createOfferForQR();
  //                                 final qrData = jsonEncode({
  //                                   "type": "offer",
  //                                   "sdp": offer["sdp"],
  //                                   "sdpType": offer["type"],
  //                                 });
  //                                 setState(() {
  //                                   _offerQRData = qrData;
  //                                   _showOfferQR = true;
  //                                   _connectionStatus =
  //                                       "Show QR code to extension";
  //                                 });
  //                               } catch (e) {
  //                                 setState(() {
  //                                   _connectionStatus = "Error: $e";
  //                                 });
  //                               }
  //                             },
  //                       icon: const Icon(Icons.qr_code),
  //                       label: const Text("Create Offer"),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   IconButton(
  //                     onPressed: _isConnected
  //                         ? () async {
  //                             await rtc.startCall();
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               const SnackBar(
  //                                 content: Text("Starting call..."),
  //                               ),
  //                             );
  //                           }
  //                         : null,
  //                     icon: const Icon(Icons.videocam),
  //                     tooltip: "Start Call",
  //                     style: IconButton.styleFrom(
  //                       backgroundColor: Colors.green[50],
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: _isConnected
  //                         ? () async {
  //                             final result = await FilePicker.platform
  //                                 .pickFiles();
  //                             if (result != null &&
  //                                 result.files.single.path != null) {
  //                               final file = File(result.files.single.path!);
  //                               final fileData = await file.readAsBytes();
  //                               await rtc.sendFile(
  //                                 fileData,
  //                                 result.files.single.name,
  //                               );
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content: Text(
  //                                     "Sending file: ${result.files.single.name}",
  //                                   ),
  //                                 ),
  //                               );
  //                             }
  //                           }
  //                         : null,
  //                     icon: const Icon(Icons.attach_file),
  //                     tooltip: "Send File",
  //                     style: IconButton.styleFrom(
  //                       backgroundColor: Colors.blue[50],
  //                     ),
  //                   ),
  //                   // Reset button - show when connection failed or disconnected
  //                   if (_connectionStatus.contains("failed") ||
  //                       _connectionStatus.contains("disconnected") ||
  //                       _connectionStatus.contains("reset"))
  //                     IconButton(
  //                       onPressed: () async {
  //                         await rtc.reset();
  //                         setState(() {
  //                           _isConnected = false;
  //                           _connectionStatus = "Reset - Ready to connect";
  //                           _messages.clear();
  //                         });
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text(
  //                               "Connection reset. You can try connecting again.",
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                       icon: const Icon(Icons.refresh),
  //                       tooltip: "Reset Connection",
  //                       style: IconButton.styleFrom(
  //                         backgroundColor: Colors.orange[50],
  //                       ),
  //                     ),
  //                   // Reconnect button - show when connection failed
  //                   if (_connectionStatus.contains("failed") &&
  //                       peerIdCtrl.text.isNotEmpty)
  //                     IconButton(
  //                       onPressed: () async {
  //                         setState(() {
  //                           _connectionStatus = "Reconnecting...";
  //                         });
  //                         await rtc.reconnect(newPeerId: peerIdCtrl.text);
  //                       },
  //                       icon: const Icon(Icons.replay),
  //                       tooltip: "Reconnect",
  //                       style: IconButton.styleFrom(
  //                         backgroundColor: Colors.blue[50],
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Chat Section
  //         Expanded(
  //           child: Container(
  //             color: Colors.grey[50],
  //             child: Column(
  //               children: [
  //                 // Messages List
  //                 Expanded(
  //                   child: _messages.isEmpty
  //                       ? Center(
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.chat_bubble_outline,
  //                                 size: 64,
  //                                 color: Colors.grey[400],
  //                               ),
  //                               const SizedBox(height: 16),
  //                               Text(
  //                                 _isConnected
  //                                     ? "Start chatting..."
  //                                     : "Connect to start chatting",
  //                                 style: TextStyle(
  //                                   color: Colors.grey[600],
  //                                   fontSize: 16,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       : ListView.builder(
  //                           controller: _scrollController,
  //                           padding: const EdgeInsets.all(16),
  //                           itemCount: _messages.length,
  //                           itemBuilder: (context, index) {
  //                             return _buildMessageBubble(_messages[index]);
  //                           },
  //                         ),
  //                 ),

  //                 // Message Input
  //                 Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.1),
  //                         blurRadius: 4,
  //                         offset: const Offset(0, -2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: SafeArea(
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: TextField(
  //                             controller: msgCtrl,
  //                             decoration: InputDecoration(
  //                               hintText: "Type a message...",
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(24),
  //                               ),
  //                               contentPadding: const EdgeInsets.symmetric(
  //                                 horizontal: 16,
  //                                 vertical: 8,
  //                               ),
  //                               filled: true,
  //                               fillColor: Colors.grey[100],
  //                             ),
  //                             enabled: _isConnected,
  //                             onSubmitted: (_) => _sendMessage(),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         IconButton(
  //                           onPressed: _isConnected ? _sendMessage : null,
  //                           icon: const Icon(Icons.send),
  //                           color: Colors.blue,
  //                           style: IconButton.styleFrom(
  //                             backgroundColor: Colors.blue[50],
  //                             padding: const EdgeInsets.all(12),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Flutter ↔ Extension P2P"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _myPeerId == null
                                ? null
                                : () {
                                    setState(() {
                                      _offerQRData = _myPeerId;
                                      _showOfferQR = true;
                                    });
                                  },
                            icon: const Icon(Icons.qr_code),
                            label: const Text("Create QR for Peer ID"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnected
                                ? null
                                : () {
                                    setState(() {
                                      _showScanner = true;
                                    });
                                  },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text("Scan Peer ID QR"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Simple Peer ID Connection
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Simple Connection (Peer ID):",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: myIdCtrl,
                            decoration: const InputDecoration(
                              hintText: "Your Peer ID (optional)",
                              border: OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(fontSize: 11),
                            enabled: !_isConnected,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: peerIdCtrl,
                            decoration: const InputDecoration(
                              hintText: "Enter Peer ID to connect",
                              border: OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(fontSize: 11),
                            enabled: !_isConnected,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _isConnected
                                ? null
                                : () async {
                                    if (peerIdCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter a peer ID",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _connectionStatus = "Connecting...";
                                    });
                                    try {
                                      // Ensure peer service is initialized
                                      if (peerService == null ||
                                          peerService!.myPeerId == null) {
                                        final customId =
                                            myIdCtrl.text.trim().isEmpty
                                            ? null
                                            : myIdCtrl.text.trim();
                                        await peerService!.init(
                                          customId: customId,
                                        );
                                        setState(() {
                                          _myPeerId = peerService!.myPeerId;
                                        });
                                      }

                                      // Connect to peer using peer_rtc
                                      await peerService!.connectToPeer(
                                        peerIdCtrl.text.trim(),
                                      );
                                      setState(() {
                                        _isConnected = true;
                                        _usePeerService = true;
                                        _connectionStatus =
                                            "Connected via Peer ID";
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _connectionStatus =
                                            "Connection failed: $e";
                                        _isConnected = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Connection failed: $e",
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.link, size: 18),
                            label: const Text("Connect by Peer ID"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (_myPeerId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Your Peer ID: $_myPeerId",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    // const Text(
                    //   "Advanced: Manual SDP (if Peer ID fails):",
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    // ),
                    // const Text(
                    //   "(Contains full WebRTC connection info)",
                    //   style: TextStyle(fontSize: 10, color: Colors.grey),
                    // ),
                    // const SizedBox(height: 8),
                    // TextField(
                    //   controller: peerIdCtrl,
                    //   maxLines: 4,
                    //   decoration: InputDecoration(
                    //     hintText: "Paste SDP offer/answer JSON here...",
                    //     border: OutlineInputBorder(),
                    //     isDense: true,
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //   ),
                    //   style: const TextStyle(
                    //     fontSize: 11,
                    //     fontFamily: 'monospace',
                    //   ),
                    //   enabled: !_isConnected,
                    // ),
                    // const SizedBox(height: 8),
                    // ElevatedButton.icon(
                    //   onPressed: _isConnected
                    //       ? null
                    //       : () async {
                    //           if (peerIdCtrl.text.trim().isEmpty) {
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               const SnackBar(
                    //                 content: Text("Please paste the SDP data"),
                    //               ),
                    //             );
                    //             return;
                    //           }
                    //           await _processConnectionData(
                    //             peerIdCtrl.text.trim(),
                    //           );
                    //         },
                    //   icon: const Icon(Icons.link, size: 18),
                    //   label: const Text("Connect with SDP"),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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

                        // IconButton(
                        //   onPressed: _isConnected
                        //       ? () async {
                        //           final result = await FilePicker.platform
                        //               .pickFiles();
                        //           if (result != null &&
                        //               result.files.single.path != null) {
                        //             final file = File(
                        //               result.files.single.path!,
                        //             );
                        //             final fileData = await file.readAsBytes();
                        //             await rtc.sendFile(
                        //               fileData,
                        //               result.files.single.name,
                        //             );
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               SnackBar(
                        //                 content: Text(
                        //                   "Sending file: ${result.files.single.name}",
                        //                 ),
                        //               ),
                        //             );
                        //           }
                        //         }
                        //       : null,
                        //   icon: const Icon(Icons.attach_file),
                        //   tooltip: "Send File",
                        //   style: IconButton.styleFrom(
                        //     backgroundColor: Colors.blue[50],
                        //   ),
                        // ),
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
        ),
        // QR Code Modals
        if (_showOfferQR && _offerQRData != null)
          _buildQRModal(
            title: "Your Peer ID QR Code",
            data: _offerQRData!,
            onClose: () => setState(() => _showOfferQR = false),
          ),
        if (_showAnswerQR && _answerQRData != null)
          _buildQRModal(
            title: "Answer QR Code",
            data: _answerQRData!,
            onClose: () => setState(() => _showAnswerQR = false),
          ),
        if (_showScanner)
          _buildQRScanner(
            onScan: (data) async {
              setState(() => _showScanner = false);
              await _processConnectionData(data);
            },
            onClose: () => setState(() => _showScanner = false),
          ),
      ],
    );
  }

  Widget _buildQRModal({
    required String title,
    required String data,
    required VoidCallback onClose,
  }) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // QR Code
              QrImageView(data: data, version: QrVersions.auto, size: 250),
              const SizedBox(height: 16),
              Text(
                "Scan this QR code to share your Peer ID",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              // Manual Input Section
              const Text(
                "Or copy/paste Peer ID:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  data,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: data));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Peer ID copied!")),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text("Copy Peer ID"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onClose,
                    child: const Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processConnectionData(String data) async {
    try {
      // Try to parse as JSON first (for backward compatibility)
      try {
        final decoded = jsonDecode(data);
        if (decoded["type"] == "offer") {
          await rtc.handleOfferFromQR(decoded["sdp"], decoded["sdpType"]);
          // Create answer and show QR
          final answer = await rtc.createAnswerForQR();
          final answerQR = jsonEncode({
            "type": "answer",
            "sdp": answer["sdp"],
            "sdpType": answer["type"],
          });
          setState(() {
            _answerQRData = answerQR;
            _showAnswerQR = true;
            _connectionStatus = "Show Answer QR to extension";
          });
          return;
        } else if (decoded["type"] == "answer") {
          await rtc.handleAnswerFromQR(decoded["sdp"], decoded["sdpType"]);
          setState(() {
            _connectionStatus = "Answer received - Connecting...";
          });
          return;
        }
      } catch (jsonError) {
        // Not JSON, treat as peer ID string
      }

      // Treat as peer ID string
      final peerId = data.trim();
      if (peerId.isEmpty) {
        throw Exception("Empty peer ID");
      }

      setState(() {
        _connectionStatus = "Connecting to peer: $peerId...";
      });

      // Use PeerService to connect
      if (peerService == null || peerService!.myPeerId == null) {
        await peerService!.init();
        setState(() {
          _myPeerId = peerService!.myPeerId;
        });
      }

      await peerService!.connectToPeer(peerId);
      setState(() {
        _isConnected = true;
        _usePeerService = true;
        _connectionStatus = "Connected via Peer ID";
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Connected to peer: $peerId")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() {
        _connectionStatus = "Connection failed: $e";
      });
    }
  }

  Widget _buildQRScanner({
    required Function(String) onScan,
    required VoidCallback onClose,
  }) {
    return Dialog(
      child: Container(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      onScan(barcode.rawValue!);
                      return;
                    }
                  }
                },
              ),
            ),
          ],
        ),
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

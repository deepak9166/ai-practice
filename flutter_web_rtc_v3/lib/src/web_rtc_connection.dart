import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';

import 'adm_sample.dart';
import 'capture_frame_sample.dart';
import 'data_packet_cryptor_sample.dart';
import 'device_enumeration_sample.dart';
import 'get_display_media_sample.dart';
import 'get_user_media_sample.dart';
import 'loopback_data_channel_sample.dart';
import 'loopback_sample_unified_tracks.dart';
import 'route_item.dart';

class WebRTCManualSDPPage extends StatefulWidget {
  const WebRTCManualSDPPage({super.key});

  @override
  State<WebRTCManualSDPPage> createState() => _WebRTCManualSDPPageState();
}

class _WebRTCManualSDPPageState extends State<WebRTCManualSDPPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final TextEditingController _sdpController = TextEditingController();

  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _createPeerConnection();
    // await _openUserMedia();

    _peerConnection!.onIceConnectionState = (state) {
      print('ICE connection state: $state');
    };

    _peerConnection!.onConnectionState = (state) {
      print('Peer connection state: $state');
    };
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_config);

    _peerConnection!.onTrack = (event) {
      _remoteRenderer.srcObject = event.streams[0];
    };

    _peerConnection!.onIceCandidate = (candidate) {
      debugPrint('ICE candidate: ${candidate.toMap()}');
      // Manual demo → ignoring ICE exchange
    };
  }

  Future<void> _openUserMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localRenderer.srcObject = stream;
    _localStream = stream;

    for (var track in stream.getTracks()) {
      _peerConnection!.addTrack(track, stream);
    }
  }

  /// DEVICE A
  Future<void> _createOffer() async {
    await _openUserMedia();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // ✅ Proper JSON
    _sdpController.text = jsonEncode(offer.toMap());
  }

  /// DEVICE B
  Future<void> _setRemoteOfferAndCreateAnswer() async {
    if (_sdpController.text.trim().isEmpty) {
      throw Exception('SDP JSON is empty');
    }

    final Map<String, dynamic> offerMap = jsonDecode(_sdpController.text);

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offerMap['sdp'], offerMap['type']),
    );

    await _openUserMedia();

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    // ✅ Send answer as JSON
    _sdpController.text = jsonEncode(answer.toMap());
  }

  /// DEVICE A
  Future<void> _setRemoteAnswer() async {
    if (_sdpController.text.trim().isEmpty) {
      throw Exception('Answer JSON is empty');
    }

    final Map<String, dynamic> answerMap = jsonDecode(_sdpController.text);

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(answerMap['sdp'], answerMap['type']),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual SDP WebRTC')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                Expanded(child: RTCVideoView(_remoteRenderer)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _sdpController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Paste SDP here',
              ),
            ),
          ),

          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: _createOffer,
                child: const Text('Create Offer'),
              ),
              ElevatedButton(
                onPressed: _setRemoteOfferAndCreateAnswer,
                child: const Text('Set Offer & Create Answer'),
              ),
              ElevatedButton(
                onPressed: _setRemoteAnswer,
                child: const Text('Set Answer'),
              ),
            ],
          ),

          const SizedBox(height: 10),
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

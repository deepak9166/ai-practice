// Peer service using peer_rtc package for simple peer ID connections
import 'package:peer_rtc/peer_rtc.dart';

class PeerService {
  Peer? peer;
  DataConnection? dataConnection;
  String? myPeerId;
  bool isConnected = false;

  Function(String message)? onMessageReceived;
  Function(String status)? onConnectionStatusChanged;
  Function(bool isConnected)? onConnectionStateChanged;

  // Initialize peer connection
  Future<String> init({String? customId}) async {
    try {
      onConnectionStatusChanged?.call("Initializing peer connection...");

      // Create peer with optional custom ID
      peer = Peer(id: customId, options: PeerOptions(autoReconnect: true));

      // Listen for peer open event to get ID
      peer!.onOpen.listen((id) {
        myPeerId =
            id ?? customId ?? "peer_${DateTime.now().millisecondsSinceEpoch}";
        onConnectionStatusChanged?.call("Peer ready. Your ID: $myPeerId");
      });

      // Listen for incoming connections
      peer!.onConnection.listen((connection) {
        dataConnection = connection;
        _setupDataConnection(dataConnection!);
        onConnectionStatusChanged?.call(
          "Incoming connection from: ${connection.peer}",
        );
      });

      // Listen for errors
      peer!.onError.listen((error) {
        onConnectionStatusChanged?.call("Peer error: $error");
      });

      // Wait a bit for peer to initialize, then return ID
      await Future.delayed(const Duration(milliseconds: 500));
      myPeerId =
          peer!.id ??
          customId ??
          "peer_${DateTime.now().millisecondsSinceEpoch}";

      onConnectionStatusChanged?.call("Peer initialized. Your ID: $myPeerId");
      onConnectionStateChanged?.call(false);

      return myPeerId!;
    } catch (error) {
      onConnectionStatusChanged?.call("Error initializing peer: $error");
      rethrow;
    }
  }

  // Connect to another peer by ID
  Future<void> connectToPeer(String peerId) async {
    if (peer == null) {
      throw Exception("Peer not initialized. Call init() first.");
    }

    try {
      onConnectionStatusChanged?.call("Connecting to peer: $peerId...");

      // Connect using peer_rtc
      dataConnection = peer!.connect(peerId);
      _setupDataConnection(dataConnection!);

      onConnectionStatusChanged?.call("Connection initiated to: $peerId");
    } catch (error) {
      onConnectionStatusChanged?.call("Connection failed: $error");
      rethrow;
    }
  }

  void _setupDataConnection(DataConnection conn) {
    conn.onOpen.listen((_) {
      isConnected = true;
      onConnectionStatusChanged?.call("Data channel opened with ${conn.peer}");
      onConnectionStateChanged?.call(true);
    });

    conn.onData.listen((data) {
      print('PeerService: Received data: $data (type: ${data.runtimeType})');
      String message;
      if (data is String) {
        message = data;
      } else {
        message = data.toString();
      }
      print('PeerService: Processed message: $message');
      onMessageReceived?.call(message);
    });

    conn.onClose.listen((_) {
      isConnected = false;
      onConnectionStatusChanged?.call("Connection closed");
      onConnectionStateChanged?.call(false);
    });

    conn.onError.listen((error) {
      onConnectionStatusChanged?.call("Connection error: $error");
    });
  }

  // Send message
  void sendMessage(String message) {
    print('PeerService: Sending message: $message');
    print(
      'PeerService: Connection state - dataConnection: ${dataConnection != null}, isConnected: $isConnected',
    );

    if (dataConnection != null && isConnected) {
      try {
        dataConnection!.send(message);
        print('PeerService: Message sent successfully');
      } catch (e) {
        print('PeerService: Error sending message: $e');
        onConnectionStatusChanged?.call("Error sending message: $e");
      }
    } else {
      print('PeerService: Cannot send - not connected');
      onConnectionStatusChanged?.call("Cannot send: Not connected");
    }
  }

  void dispose() {
    dataConnection?.close();
    peer?.close();
    isConnected = false;
  }
}

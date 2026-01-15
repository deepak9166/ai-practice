import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class Signaling {
  final String url;
  late WebSocketChannel _channel;
  late String myId;

  Function(Map<String, dynamic>)? onMessage;

  Signaling(this.url);

  void connect(String userId) {
    myId = userId;
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.sink.add(jsonEncode({
      "join": true,
      "userId": myId,
    }));

    _channel.stream.listen((message) {
      onMessage?.call(jsonDecode(message));
    });
  }

  void send({
    required String to,
    required String type,
    required dynamic payload,
  }) {
    _channel.sink.add(jsonEncode({
      "from": myId,
      "to": to,
      "type": type,
      "payload": payload,
    }));
  }

  void dispose() {
    _channel.sink.close();
  }
}

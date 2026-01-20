/// Model for chat messages sent/received over DataChannel
class ChatMessage {
  final String type;
  final String message;
  final int timestamp;
  final String sender;

  ChatMessage({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      type: json['type'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as int,
      sender: json['sender'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'timestamp': timestamp,
      'sender': sender,
    };
  }

  /// Creates a chat message from mobile app
  factory ChatMessage.create(String message) {
    return ChatMessage(
      type: 'chat',
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      sender: 'mobile',
    );
  }
}


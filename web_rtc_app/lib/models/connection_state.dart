/// Enum for WebRTC connection states
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
  reconnecting,
}

/// Extension methods for ConnectionState
extension ConnectionStateExtension on ConnectionState {
  String get displayName {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.connected:
        return 'Connected';
      case ConnectionState.failed:
        return 'Connection Failed';
      case ConnectionState.reconnecting:
        return 'Reconnecting...';
    }
  }

  bool get isConnected => this == ConnectionState.connected;
  bool get isConnecting => this == ConnectionState.connecting || this == ConnectionState.reconnecting;
}


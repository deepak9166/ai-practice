// Direct P2P signaling via QR code - no WebSocket needed
class Signaling {
  Function(Map<String, dynamic>)? onMessage;

  Signaling();

  // No connection needed - we use QR codes
  void connect(String userId) {
    // No-op for direct P2P
  }

  // No send needed - we use QR codes
  void send({
    required String to,
    required String type,
    required dynamic payload,
  }) {
    // No-op for direct P2P
  }

  void dispose() {
    // No-op for direct P2P
  }
}

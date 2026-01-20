/// Model for SDP offer received from Chrome Extension via QR code
class SDPOffer {
  final String type;
  final String sdp;
  final Map<String, dynamic> meta;

  SDPOffer({
    required this.type,
    required this.sdp,
    required this.meta,
  });

  factory SDPOffer.fromJson(Map<String, dynamic> json) {
    return SDPOffer(
      type: json['type'] as String,
      sdp: json['sdp'] as String,
      meta: json['meta'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sdp': sdp,
      'meta': meta,
    };
  }

  /// Validates if the SDP offer has required fields
  bool isValid() {
    return type == 'offer' && sdp.isNotEmpty && meta.isNotEmpty;
  }
}


class BlogHistoryEntry {
  final String url;
  final String slugUrl;
  final String title;
  final DateTime createdAt;
  final String status; // 'generated' | 'published'

  const BlogHistoryEntry({
    required this.url,
    required this.slugUrl,
    required this.title,
    required this.createdAt,
    this.status = 'generated',
  });

  factory BlogHistoryEntry.fromJson(Map<String, dynamic> json) {
    return BlogHistoryEntry(
      url: json['url'] ?? '',
      slugUrl: json['slugUrl'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'generated',
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'slugUrl': slugUrl,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  BlogHistoryEntry copyWith({String? status}) {
    return BlogHistoryEntry(
      url: url,
      slugUrl: slugUrl,
      title: title,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  /// Normalize a URL for duplicate comparison.
  static String normalizeUrl(String url) {
    return url.trim().toLowerCase().replaceAll(RegExp(r'/+$'), '');
  }
}

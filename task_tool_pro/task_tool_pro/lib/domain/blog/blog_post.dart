/// Represents a single section of a blog post with a heading and body content.
class BlogSection {
  const BlogSection({
    required this.heading,
    required this.content,
  });

  final String heading;
  final String content;

  BlogSection copyWith({String? heading, String? content}) {
    return BlogSection(
      heading: heading ?? this.heading,
      content: content ?? this.content,
    );
  }
}

/// A fully structured blog post produced by an AI provider.
class BlogPost {
  const BlogPost({
    required this.title,
    required this.introduction,
    required this.sections,
    required this.conclusion,
    required this.generatedAt,
  });

  final String title;
  final String introduction;
  final List<BlogSection> sections;
  final String conclusion;
  final DateTime generatedAt;

  BlogPost copyWith({
    String? title,
    String? introduction,
    List<BlogSection>? sections,
    String? conclusion,
    DateTime? generatedAt,
  }) {
    return BlogPost(
      title: title ?? this.title,
      introduction: introduction ?? this.introduction,
      sections: sections ?? this.sections,
      conclusion: conclusion ?? this.conclusion,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Returns the entire post as plain text suitable for copying to clipboard.
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln();
    buffer.writeln(introduction);
    buffer.writeln();
    for (final section in sections) {
      buffer.writeln(section.heading);
      buffer.writeln(section.content);
      buffer.writeln();
    }
    buffer.writeln('Conclusion');
    buffer.writeln(conclusion);
    return buffer.toString().trim();
  }

  /// Returns the full blog content as an HTML string.
  String toHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<p>${_escapeHtml(introduction)}</p>');
    for (final section in sections) {
      buffer.writeln('<h2>${_escapeHtml(section.heading)}</h2>');
      buffer.writeln('<p>${_escapeHtml(section.content)}</p>');
    }
    buffer.writeln('<h2>Conclusion</h2>');
    buffer.writeln('<p>${_escapeHtml(conclusion)}</p>');
    return buffer.toString().trim();
  }

  /// Returns the full blog content in EditorJS JSON format.
  String toEditorJs() {
    final blocks = <Map<String, dynamic>>[];
    var blockIndex = 0;

    // Introduction paragraph
    blocks.add({
      'id': _editorJsBlockId(blockIndex++),
      'type': 'paragraph',
      'data': {'text': _escapeHtml(introduction)},
    });

    // Sections
    for (final section in sections) {
      blocks.add({
        'id': _editorJsBlockId(blockIndex++),
        'type': 'header',
        'data': {'text': _escapeHtml(section.heading), 'level': 2},
      });
      blocks.add({
        'id': _editorJsBlockId(blockIndex++),
        'type': 'paragraph',
        'data': {'text': _escapeHtml(section.content)},
      });
    }

    // Conclusion
    blocks.add({
      'id': _editorJsBlockId(blockIndex++),
      'type': 'header',
      'data': {'text': 'Conclusion', 'level': 2},
    });
    blocks.add({
      'id': _editorJsBlockId(blockIndex++),
      'type': 'paragraph',
      'data': {'text': _escapeHtml(conclusion)},
    });

    final json = {
      'time': generatedAt.millisecondsSinceEpoch,
      'blocks': blocks,
      'version': '2.29.1',
    };

    return _jsonEncode(json);
  }

  /// Generates a URL-friendly slug from the title.
  String toSlugUrl() {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Returns a short summary from the introduction (first ~200 chars).
  String toSummary() {
    if (introduction.length <= 200) return introduction;
    final truncated = introduction.substring(0, 200);
    final lastSpace = truncated.lastIndexOf(' ');
    return '${lastSpace > 0 ? truncated.substring(0, lastSpace) : truncated}...';
  }

  /// Generates keywords from the title.
  String toKeywords() {
    final stopWords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'is', 'it', 'by', 'with', 'as', 'this', 'that', 'from', 'are', 'was', 'were', 'be', 'been', 'has', 'have', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'can', 'not', 'no', 'how', 'what', 'why', 'when', 'where', 'who', 'which'};
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .take(8)
        .join(', ');
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  static String _editorJsBlockId(int index) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final hash = index.hashCode.abs();
    final buffer = StringBuffer();
    for (var i = 0; i < 10; i++) {
      buffer.write(chars[(hash + i * 7) % chars.length]);
    }
    return buffer.toString();
  }

  /// Simple JSON encoder to avoid importing dart:convert in the model.
  static String _jsonEncode(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t')}"';
    }
    if (value is num || value is bool) return '$value';
    if (value is List) {
      return '[${value.map(_jsonEncode).join(',')}]';
    }
    if (value is Map<String, dynamic>) {
      final entries = value.entries
          .map((e) => '${_jsonEncode(e.key)}:${_jsonEncode(e.value)}');
      return '{${entries.join(',')}}';
    }
    return '"$value"';
  }
}

/// Holds the Hindi-translated version of a blog post.
class BlogPostHindi {
  const BlogPostHindi({
    required this.title,
    required this.description,
    required this.summary,
    required this.keywords,
    required this.descriptionJson,
  });

  final String title;
  final String description;
  final String summary;
  final String keywords;
  final String descriptionJson;
}

/// Which AI backend will be used for generation.
enum ApiProvider {
  openai,
  gemini,
  ollama;

  String get displayName {
    switch (this) {
      case ApiProvider.openai:
        return 'OpenAI (ChatGPT)';
      case ApiProvider.gemini:
        return 'Google Gemini';
      case ApiProvider.ollama:
        return 'Ollama (Local)';
    }
  }
}

/// The tone in which the blog post should be written.
enum BlogTone {
  professional,
  casual,
  technical;

  String get displayName {
    switch (this) {
      case BlogTone.professional:
        return 'Professional';
      case BlogTone.casual:
        return 'Casual';
      case BlogTone.technical:
        return 'Technical';
    }
  }
}

/// Current lifecycle state of a blog generation request.
enum BlogGenerationStatus {
  idle,
  loading,
  success,
  error,
}

/// A single item from the preptm dropdown APIs.
class DropdownItem {
  final String text;
  final int value;
  final String? slugUrl;

  const DropdownItem({required this.text, required this.value, this.slugUrl});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    final otherData = json['otherData'] as Map<String, dynamic>?;
    return DropdownItem(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
      slugUrl: otherData?['slugUrl'] ?? otherData?['SlugUrl'],
    );
  }
}

/// A single FAQ item for an article.
class ArticleFaq {
  final int id;
  final String que;
  final String ans;
  final String queHindi;
  final String ansHindi;
  final bool isUpdate;

  const ArticleFaq({
    this.id = 0,
    required this.que,
    required this.ans,
    required this.queHindi,
    required this.ansHindi,
    this.isUpdate = false,
  });

  factory ArticleFaq.fromJson(Map<String, dynamic> json) {
    return ArticleFaq(
      id: json['id'] ?? 0,
      que: json['que'] ?? '',
      ans: json['ans'] ?? '',
      queHindi: json['queHindi'] ?? '',
      ansHindi: json['ansHindi'] ?? '',
      isUpdate: json['isUpdate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'que': que,
        'ans': ans,
        'queHindi': queHindi,
        'ansHindi': ansHindi,
        'isUpdate': isUpdate,
      };
}

/// Request model for POST /process-blog.
class ProcessBlogRequest {
  final String url;
  final String mode;
  final int categoryId;
  final List<int> tags;
  final String? geminiApiKey;

  const ProcessBlogRequest({
    required this.url,
    this.mode = 'local',
    this.categoryId = 0,
    this.tags = const [],
    this.geminiApiKey,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'mode': mode,
    'category_id': categoryId,
    'tags': tags,
    if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
  };
}

/// Full article data returned by the Python AI service.
class BlogArticleData {
  final String title;
  final String titleHindi;
  final int articleType;
  final String slugUrl;
  final String keywords;
  final String keywordHindi;
  final String description;
  final String descriptionHindi;
  final String summary;
  final String summaryHindi;
  final String thumbnail;
  final String? thumbnailCredit;
  final List<ArticleFaq> articleFaqsDTOs;
  final List<int> articleTagsDTOs;
  final String descriptionJson;
  final String descriptionJsonHindi;

  BlogArticleData({
    required this.title,
    required this.titleHindi,
    required this.articleType,
    required this.slugUrl,
    required this.keywords,
    required this.keywordHindi,
    required this.description,
    required this.descriptionHindi,
    required this.summary,
    required this.summaryHindi,
    this.thumbnail = '',
    this.thumbnailCredit,
    this.articleFaqsDTOs = const [],
    this.articleTagsDTOs = const [],
    this.descriptionJson = '{}',
    this.descriptionJsonHindi = '{}',
  });

  factory BlogArticleData.fromJson(Map<String, dynamic> json) {
    return BlogArticleData(
      title: json['title'] ?? '',
      titleHindi: json['titleHindi'] ?? '',
      articleType: json['articleType'] ?? 0,
      slugUrl: json['slugUrl'] ?? '',
      keywords: json['keywords'] ?? '',
      keywordHindi: json['keywordHindi'] ?? '',
      description: json['description'] ?? '',
      descriptionHindi: json['descriptionHindi'] ?? '',
      summary: json['summary'] ?? '',
      summaryHindi: json['summaryHindi'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      thumbnailCredit: json['thumbnailCredit'],
      articleFaqsDTOs: (json['articleFaqsDTOs'] as List<dynamic>?)
              ?.map((e) => ArticleFaq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      articleTagsDTOs: List<int>.from(json['articleTagsDTOs'] ?? []),
      descriptionJson: json['descriptionJson'] ?? '{}',
      descriptionJsonHindi: json['descriptionJsonHindi'] ?? '{}',
    );
  }

  BlogArticleData copyWith({
    String? title,
    String? titleHindi,
    int? articleType,
    String? slugUrl,
    String? keywords,
    String? keywordHindi,
    String? description,
    String? descriptionHindi,
    String? summary,
    String? summaryHindi,
    String? thumbnail,
    String? thumbnailCredit,
    List<ArticleFaq>? articleFaqsDTOs,
    List<int>? articleTagsDTOs,
    String? descriptionJson,
    String? descriptionJsonHindi,
  }) {
    return BlogArticleData(
      title: title ?? this.title,
      titleHindi: titleHindi ?? this.titleHindi,
      articleType: articleType ?? this.articleType,
      slugUrl: slugUrl ?? this.slugUrl,
      keywords: keywords ?? this.keywords,
      keywordHindi: keywordHindi ?? this.keywordHindi,
      description: description ?? this.description,
      descriptionHindi: descriptionHindi ?? this.descriptionHindi,
      summary: summary ?? this.summary,
      summaryHindi: summaryHindi ?? this.summaryHindi,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailCredit: thumbnailCredit ?? this.thumbnailCredit,
      articleFaqsDTOs: articleFaqsDTOs ?? this.articleFaqsDTOs,
      articleTagsDTOs: articleTagsDTOs ?? this.articleTagsDTOs,
      descriptionJson: descriptionJson ?? this.descriptionJson,
      descriptionJsonHindi: descriptionJsonHindi ?? this.descriptionJsonHindi,
    );
  }

  /// Wrap any bare `<table>` not already inside `<div class="editor-table">`
  /// so the publish API renders them correctly.
  static String _wrapBareTables(String html) {
    // Match <table ...>...</table> that is NOT preceded by <div class="editor-table">
    return html.replaceAllMapped(
      RegExp(
        r'(?<!<div class="editor-table"\s*>)(<table[\s\S]*?</table>)',
        caseSensitive: false,
      ),
      (m) => '<div class="editor-table" >${m.group(1)}</div>',
    );
  }

  Map<String, dynamic> toPublishJson() {
    // Wrap bare <table> tags in <div class="editor-table"> for proper formatting
    final enHtml = _wrapBareTables(description);
    final hiHtml = _wrapBareTables(descriptionHindi);

    // Convert HTML descriptions to EditorJS JSON before publishing
    final enJson = descriptionJson == '{}'
        ? EditorJsConverter.htmlToEditorJs(enHtml)
        : descriptionJson;
    final hiJson = descriptionJsonHindi == '{}'
        ? EditorJsConverter.htmlToEditorJs(hiHtml)
        : descriptionJsonHindi;

    return {
      'id': 0,
      'title': title,
      'titleHindi': titleHindi,
      'articleType': articleType,
      'slugUrl': slugUrl,
      'keywords': keywords,
      'keywordHindi': keywordHindi,
      'description': enHtml,
      'descriptionHindi': hiHtml,
      'summary': summary,
      'summaryHindi': summaryHindi,
      'thumbnail': thumbnail,
      'thumbnailCredit': thumbnailCredit,
      'articleFaqsDTOs': articleFaqsDTOs.map((f) => f.toJson()).toList(),
      'articleTagsDTOs': articleTagsDTOs,
      'descriptionJson': enJson,
      'descriptionJsonHindi': hiJson,
    };
  }
}

/// Converts HTML content to Editor.js JSON format.
class EditorJsConverter {
  EditorJsConverter._();

  /// Parse HTML string into Editor.js JSON string.
  static String htmlToEditorJs(String html) {
    if (html.trim().isEmpty) {
      return _encode({'time': _now(), 'blocks': [], 'version': '2.29.1'});
    }

    final blocks = <Map<String, dynamic>>[];
    var idCounter = 0;

    // Clean: remove scripts, styles, ads, comments
    var cleaned = html
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
        .replaceAll(RegExp(r'<iframe[^>]*>[\s\S]*?</iframe>', caseSensitive: false), '');

    // Split into top-level block elements (including table)
    final blockPattern = RegExp(
      r'<(h[1-6]|p|ul|ol|li|div|blockquote|table)(\s[^>]*)?>[\s\S]*?</\1>',
      caseSensitive: false,
    );

    final matches = blockPattern.allMatches(cleaned);

    if (matches.isEmpty) {
      // No block elements — treat entire content as one paragraph
      final text = _stripTags(cleaned).trim();
      if (text.isNotEmpty) {
        blocks.add(_paragraph(_blockId(idCounter++), text));
      }
    } else {
      for (final match in matches) {
        final tag = match.group(1)!.toLowerCase();
        final fullHtml = match.group(0)!;
        final innerHtml = fullHtml
            .replaceFirst(RegExp(r'^<[^>]+>'), '')
            .replaceFirst(RegExp(r'<\/[^>]+>$'), '');

        if (tag.startsWith('h') && tag.length == 2) {
          // Header h1-h6
          final level = int.tryParse(tag[1]) ?? 2;
          final text = _stripTags(innerHtml).trim();
          if (text.isNotEmpty) {
            blocks.add(_header(_blockId(idCounter++), text, level));
          }
        } else if (tag == 'ul' || tag == 'ol') {
          // List
          final items = RegExp(r'<li[^>]*>([\s\S]*?)</li>', caseSensitive: false)
              .allMatches(innerHtml)
              .map((m) => _stripTags(m.group(1) ?? '').trim())
              .where((s) => s.isNotEmpty)
              .toList();
          if (items.isNotEmpty) {
            blocks.add(_list(
              _blockId(idCounter++),
              items,
              tag == 'ol' ? 'ordered' : 'unordered',
            ));
          }
        } else if (tag == 'table') {
          // Table
          final tableBlock = _parseTable(_blockId(idCounter++), fullHtml);
          if (tableBlock != null) blocks.add(tableBlock);
        } else if (tag == 'div' && innerHtml.contains(RegExp(r'<table', caseSensitive: false))) {
          // div wrapping a table (e.g. <div class="editor-table"><table>...</table></div>)
          final tableBlock = _parseTable(_blockId(idCounter++), innerHtml);
          if (tableBlock != null) blocks.add(tableBlock);
        } else {
          // p, div, blockquote → paragraph
          final text = _stripTags(innerHtml).trim();
          if (text.isNotEmpty) {
            blocks.add(_paragraph(_blockId(idCounter++), text));
          }
        }
      }
    }

    final editorJs = {
      'time': _now(),
      'blocks': blocks,
      'version': '2.29.1',
    };

    return _encode(editorJs);
  }

  // -- Block builders --

  static Map<String, dynamic> _header(String id, String text, int level) => {
        'id': id,
        'type': 'header',
        'data': {'text': text, 'level': level},
      };

  static Map<String, dynamic> _paragraph(String id, String text) => {
        'id': id,
        'type': 'paragraph',
        'data': {'text': text},
      };

  static Map<String, dynamic> _list(
      String id, List<String> items, String style) => {
        'id': id,
        'type': 'list',
        'data': {'style': style, 'items': items},
      };

  static Map<String, dynamic> _table(
      String id, List<List<String>> content, bool withHeadings) => {
        'id': id,
        'type': 'table',
        'data': {'withHeadings': withHeadings, 'content': content},
      };

  /// Parse a <table> HTML block into an EditorJS table block.
  static Map<String, dynamic>? _parseTable(String id, String html) {
    final content = <List<String>>[];
    var withHeadings = false;

    // Check for <thead> to determine withHeadings
    if (RegExp(r'<thead', caseSensitive: false).hasMatch(html)) {
      withHeadings = true;
    }

    // Extract all <tr> rows
    final rowPattern = RegExp(
      r'<tr[^>]*>([\s\S]*?)</tr>',
      caseSensitive: false,
    );

    for (final rowMatch in rowPattern.allMatches(html)) {
      final rowHtml = rowMatch.group(1) ?? '';

      // Extract <th> and <td> cells
      final cellPattern = RegExp(
        r'<(?:td|th)[^>]*>([\s\S]*?)</(?:td|th)>',
        caseSensitive: false,
      );

      final cells = cellPattern
          .allMatches(rowHtml)
          .map((m) => _stripTags(m.group(1) ?? '').trim())
          .toList();

      if (cells.isNotEmpty) {
        content.add(cells);
      }
    }

    if (content.isEmpty) return null;

    // If first row has <th> but no <thead>, still mark as headings
    if (!withHeadings &&
        RegExp(r'<th[\s>]', caseSensitive: false).hasMatch(html)) {
      withHeadings = true;
    }

    return _table(id, content, withHeadings);
  }

  // -- Helpers --

  static String _stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ');
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  /// Generate a short unique block ID.
  static String _blockId(int index) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final seed = (index * 31 + 17).abs() + _now() % 10000;
    final buf = StringBuffer();
    for (var i = 0; i < 10; i++) {
      buf.write(chars[(seed + i * 13) % chars.length]);
    }
    return buf.toString();
  }

  /// Simple JSON encoder (avoids dart:convert import in domain model).
  static String _encode(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t')}"';
    }
    if (value is num || value is bool) return '$value';
    if (value is List) {
      return '[${value.map(_encode).join(',')}]';
    }
    if (value is Map<String, dynamic>) {
      final entries =
          value.entries.map((e) => '${_encode(e.key)}:${_encode(e.value)}');
      return '{${entries.join(',')}}';
    }
    return '"$value"';
  }
}

/// Wrapper for the /process-blog response.
class ProcessBlogResponse {
  final bool success;
  final String? message;
  final BlogArticleData? data;

  ProcessBlogResponse({required this.success, this.message, this.data});

  factory ProcessBlogResponse.fromJson(Map<String, dynamic> json) {
    return ProcessBlogResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? BlogArticleData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

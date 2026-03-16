import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../domain/blog/blog_post.dart';

/// Handles all HTTP communication with OpenAI and Google Gemini to generate
/// structured blog posts.
class BlogAiService {
  BlogAiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  static const _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const _publishUrl =
      'https://api.preptm.com/api/translation/article/AddUpdate';

  /// Generates a [BlogPost] using the given [provider] and credentials.
  ///
  /// Throws a [BlogAiServiceException] with a human-readable message when the
  /// request fails or the response cannot be parsed.
  Future<BlogPost> generateBlog({
    required String topic,
    required BlogTone tone,
    required int targetWordCount,
    required ApiProvider provider,
    required String apiKey,
    String ollamaModel = 'llama3.1',
    String ollamaBaseUrl = 'http://localhost:11434',
  }) async {
    final prompt = _buildPrompt(
      topic: topic,
      tone: tone,
      targetWordCount: targetWordCount,
    );

    final String rawText;
    switch (provider) {
      case ApiProvider.openai:
        rawText = await _callOpenAi(prompt: prompt, apiKey: apiKey);
      case ApiProvider.gemini:
        rawText = await _callGemini(prompt: prompt, apiKey: apiKey);
      case ApiProvider.ollama:
        rawText = await _callOllama(
          prompt: prompt,
          model: ollamaModel,
          baseUrl: ollamaBaseUrl,
        );
    }

    return _parseResponse(rawText);
  }

  // ---------------------------------------------------------------------------
  // Prompt construction
  // ---------------------------------------------------------------------------

  String _buildPrompt({
    required String topic,
    required BlogTone tone,
    required int targetWordCount,
  }) {
    return '''You are a professional blog writer. Write a complete, well-structured blog post on the following topic.

Topic: $topic
Tone: ${tone.displayName}
Target word count: approximately $targetWordCount words

You MUST respond with ONLY the following plain-text format — no markdown fences, no JSON, no extra commentary:

TITLE: <the blog title here>

INTRODUCTION:
<one or two paragraphs that introduce the topic>

SECTION: <Section 1 Heading>
<section 1 body paragraphs>

SECTION: <Section 2 Heading>
<section 2 body paragraphs>

SECTION: <Section 3 Heading>
<section 3 body paragraphs>

CONCLUSION:
<concluding paragraph(s)>

Follow this format exactly. Each block must be separated by a blank line. Do not add any text before TITLE: or after the conclusion block.''';
  }

  // ---------------------------------------------------------------------------
  // OpenAI
  // ---------------------------------------------------------------------------

  Future<String> _callOpenAi({
    required String prompt,
    required String apiKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _openAiUrl,
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional blog writer. Always respond using the exact structured format provided by the user.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;
      if (body == null) {
        throw BlogAiServiceException('Empty response from OpenAI.');
      }

      if (response.statusCode == 401) {
        throw BlogAiServiceException(
          'Invalid OpenAI API key. Please check your key in settings.',
        );
      }
      if (response.statusCode == 429) {
        throw BlogAiServiceException(
          'OpenAI rate limit reached. Please wait a moment and try again.',
        );
      }
      if (response.statusCode != 200) {
        final errorMsg =
            (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
            'Unknown error from OpenAI (status ${response.statusCode}).';
        throw BlogAiServiceException(errorMsg);
      }

      final choices = body['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw BlogAiServiceException('OpenAI returned no choices.');
      }

      final content =
          (choices.first as Map<String, dynamic>)['message']?['content']
              as String?;
      if (content == null || content.trim().isEmpty) {
        throw BlogAiServiceException('OpenAI returned empty content.');
      }

      return content.trim();
    } on BlogAiServiceException {
      rethrow;
    } on DioException catch (e) {
      throw BlogAiServiceException(_dioErrorMessage(e));
    } catch (e) {
      throw BlogAiServiceException('Unexpected error calling OpenAI: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Gemini
  // ---------------------------------------------------------------------------

  Future<String> _callGemini({
    required String prompt,
    required String apiKey,
  }) async {
    try {
      final url = '$_geminiUrl?key=$apiKey';

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7},
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;

      print('Gemini raw response: ${jsonEncode(body)}'); // Debug log
      if (body == null) {
        throw BlogAiServiceException('Empty response from Gemini.');
      }

      if (response.statusCode == 400) {
        final message =
            (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
            'Bad request to Gemini API.';
        throw BlogAiServiceException(message);
      }
      if (response.statusCode == 403) {
        throw BlogAiServiceException(
          'Invalid Gemini API key. Please check your key in settings.',
        );
      }
      if (response.statusCode != 200) {
        final errorMsg =
            (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
            'Unknown error from Gemini (status ${response.statusCode}).';
        throw BlogAiServiceException(errorMsg);
      }

      final candidates = body['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw BlogAiServiceException('Gemini returned no candidates.');
      }

      final parts =
          (candidates.first as Map<String, dynamic>)['content']?['parts']
              as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw BlogAiServiceException('Gemini returned empty parts.');
      }

      final text = (parts.first as Map<String, dynamic>)['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw BlogAiServiceException('Gemini returned empty text.');
      }

      return text.trim();
    } on BlogAiServiceException {
      rethrow;
    } on DioException catch (e) {
      throw BlogAiServiceException(_dioErrorMessage(e));
    } catch (e) {
      throw BlogAiServiceException('Unexpected error calling Gemini: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Ollama (Local)
  // ---------------------------------------------------------------------------

  Future<String> _callOllama({
    required String prompt,
    required String model,
    required String baseUrl,
  }) async {
    try {
      final url = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/chat';

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional blog writer. Always respond using the exact structured format provided by the user.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      final body = response.data;
      if (body == null) {
        throw BlogAiServiceException('Empty response from Ollama.');
      }

      if (response.statusCode == 404) {
        throw BlogAiServiceException(
          'Model "$model" not found. Run: ollama pull $model',
        );
      }
      if (response.statusCode != 200) {
        final errorMsg = body['error'] as String? ??
            'Unknown error from Ollama (status ${response.statusCode}).';
        throw BlogAiServiceException(errorMsg);
      }

      final content =
          (body['message'] as Map<String, dynamic>?)?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw BlogAiServiceException('Ollama returned empty content.');
      }

      return content.trim();
    } on BlogAiServiceException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw BlogAiServiceException(
          'Cannot connect to Ollama at $baseUrl. '
          'Make sure Ollama is running (ollama serve).',
        );
      }
      throw BlogAiServiceException(_dioErrorMessage(e));
    } catch (e) {
      throw BlogAiServiceException('Unexpected error calling Ollama: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Response parsing
  // ---------------------------------------------------------------------------

  BlogPost _parseResponse(String rawText) {
    try {
      // Strip any markdown code fences the model may have added despite instructions
      var text = rawText
          .replaceAll(RegExp(r'```[a-z]*\n?'), '')
          .replaceAll('```', '')
          .trim();

      // ---- Extract TITLE ----
      final titleMatch = RegExp(
        r'TITLE:\s*(.+)',
        caseSensitive: false,
      ).firstMatch(text);
      final title = titleMatch?.group(1)?.trim() ?? 'Untitled Blog Post';

      // ---- Extract INTRODUCTION ----
      final introMatch = RegExp(
        r'INTRODUCTION:\s*\n([\s\S]+?)(?=\nSECTION:|\nCONCLUSION:)',
        caseSensitive: false,
      ).firstMatch(text);
      final introduction = introMatch?.group(1)?.trim() ?? '';

      // ---- Extract SECTIONS ----
      final sectionMatches = RegExp(
        r'SECTION:\s*(.+?)\n([\s\S]+?)(?=\nSECTION:|\nCONCLUSION:|$)',
        caseSensitive: false,
      ).allMatches(text);

      final sections = sectionMatches.map((m) {
        return BlogSection(
          heading: m.group(1)?.trim() ?? '',
          content: m.group(2)?.trim() ?? '',
        );
      }).toList();

      // ---- Extract CONCLUSION ----
      final conclusionMatch = RegExp(
        r'CONCLUSION:\s*\n([\s\S]+?)$',
        caseSensitive: false,
      ).firstMatch(text);
      final conclusion = conclusionMatch?.group(1)?.trim() ?? '';

      // Guard: if nothing was parsed meaningfully, surface the raw text as a
      // single section so the user still sees output rather than a blank screen.
      if (introduction.isEmpty && sections.isEmpty && conclusion.isEmpty) {
        return BlogPost(
          title: title,
          introduction: text,
          sections: const [],
          conclusion: '',
          generatedAt: DateTime.now(),
        );
      }

      return BlogPost(
        title: title,
        introduction: introduction,
        sections: sections,
        conclusion: conclusion,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw BlogAiServiceException(
        'Could not parse the AI response into a blog post. Raw output was returned.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Hindi translation
  // ---------------------------------------------------------------------------

  /// Translates the blog post content to Hindi using the selected AI provider.
  Future<BlogPostHindi> translateToHindi({
    required BlogPost post,
    required ApiProvider provider,
    required String apiKey,
    String ollamaModel = 'llama3.1',
    String ollamaBaseUrl = 'http://localhost:11434',
  }) async {
    final prompt =
        '''Translate the following blog content to Hindi. Respond in EXACTLY this format — no markdown fences, no extra text:

TITLE_HINDI: <translated title>

DESCRIPTION_HINDI:
<full blog translated to Hindi as HTML paragraphs with <p> and <h2> tags>

SUMMARY_HINDI:
<short 1-2 sentence summary in Hindi>

KEYWORDS_HINDI:
<comma-separated keywords in Hindi>

Here is the English content to translate:

Title: ${post.title}

${post.toPlainText()}''';

    final String rawText;
    switch (provider) {
      case ApiProvider.openai:
        rawText = await _callOpenAi(prompt: prompt, apiKey: apiKey);
      case ApiProvider.gemini:
        rawText = await _callGemini(prompt: prompt, apiKey: apiKey);
      case ApiProvider.ollama:
        rawText = await _callOllama(
          prompt: prompt,
          model: ollamaModel,
          baseUrl: ollamaBaseUrl,
        );
    }

    return _parseHindiResponse(rawText, post);
  }

  BlogPostHindi _parseHindiResponse(String rawText, BlogPost originalPost) {
    var text = rawText
        .replaceAll(RegExp(r'```[a-z]*\n?'), '')
        .replaceAll('```', '')
        .trim();

    final titleMatch = RegExp(
      r'TITLE_HINDI:\s*(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    final title = titleMatch?.group(1)?.trim() ?? originalPost.title;

    final descMatch = RegExp(
      r'DESCRIPTION_HINDI:\s*\n([\s\S]+?)(?=\nSUMMARY_HINDI:|\nKEYWORDS_HINDI:|$)',
      caseSensitive: false,
    ).firstMatch(text);
    final description = descMatch?.group(1)?.trim() ?? '';

    final summaryMatch = RegExp(
      r'SUMMARY_HINDI:\s*\n([\s\S]+?)(?=\nKEYWORDS_HINDI:|$)',
      caseSensitive: false,
    ).firstMatch(text);
    final summary = summaryMatch?.group(1)?.trim() ?? '';

    final keywordsMatch = RegExp(
      r'KEYWORDS_HINDI:\s*\n([\s\S]+?)$',
      caseSensitive: false,
    ).firstMatch(text);
    final keywords = keywordsMatch?.group(1)?.trim() ?? '';

    // Build EditorJS JSON for Hindi description
    final hindiDescriptionJson = _buildEditorJsFromHtml(description);

    return BlogPostHindi(
      title: title,
      description: description.startsWith('<')
          ? description
          : '<p>$description</p>',
      summary: summary,
      keywords: keywords,
      descriptionJson: hindiDescriptionJson,
    );
  }

  String _buildEditorJsFromHtml(String htmlContent) {
    // Extract text blocks from HTML for EditorJS format
    final blocks = <Map<String, dynamic>>[];
    final paragraphs = htmlContent.split(RegExp(r'</?(?:p|h[1-6])>'));
    var blockIndex = 0;
    for (final p in paragraphs) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;
      blocks.add({
        'id': _generateBlockId(blockIndex++),
        'type': 'paragraph',
        'data': {'text': trimmed},
      });
    }

    if (blocks.isEmpty) {
      blocks.add({
        'id': _generateBlockId(0),
        'type': 'paragraph',
        'data': {'text': htmlContent},
      });
    }

    final json = {
      'time': DateTime.now().millisecondsSinceEpoch,
      'blocks': blocks,
      'version': '2.29.1',
    };
    return jsonEncode(json);
  }

  String _generateBlockId(int index) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final hash = (index * 31 + 17).abs();
    final buffer = StringBuffer();
    for (var i = 0; i < 10; i++) {
      buffer.write(chars[(hash + i * 13) % chars.length]);
    }
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Publish to API
  // ---------------------------------------------------------------------------

  /// Publishes the blog post to the preptm API.
  Future<void> publishBlog({
    required BlogPost post,
    required BlogPostHindi hindi,
    required String authToken,
  }) async {
    final payload = {
      'id': 0,
      'title': post.title,
      'titleHindi': hindi.title,
      'articleType': 38,
      'slugUrl': post.toSlugUrl(),
      'keywords': post.toKeywords(),
      'keywordHindi': hindi.keywords,
      'description': post.toHtml(),
      'descriptionHindi': hindi.description,
      'summary': post.toSummary(),
      'summaryHindi': hindi.summary,
      'thumbnail': '',
      'thumbnailCredit': null,
      'articleFaqsDTOs': <dynamic>[],
      'articleTagsDTOs': [6, 9],
      'descriptionJson': post.toEditorJs(),
      'descriptionJsonHindi': hindi.descriptionJson,
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _publishUrl,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw BlogAiServiceException(
          'Unauthorized. Please check your auth token in settings.',
        );
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw BlogAiServiceException(
          'Failed to publish blog (status ${response.statusCode}).',
        );
      }
    } on BlogAiServiceException {
      rethrow;
    } on DioException catch (e) {
      throw BlogAiServiceException(_dioErrorMessage(e));
    } catch (e) {
      throw BlogAiServiceException('Failed to publish blog: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Network error. Check your internet connection.';
      default:
        return 'Network request failed: ${e.message ?? e.type.name}';
    }
  }
}

/// Thrown by [BlogAiService] with a message suitable for display to the user.
class BlogAiServiceException implements Exception {
  const BlogAiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

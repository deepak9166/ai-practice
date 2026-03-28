import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/blog_history_repository.dart';
import '../../../data/dropdown_cache_repository.dart';
import '../../../domain/blog/blog_article.dart';
import '../../../domain/blog/blog_history_entry.dart';

const _kGeminiApiKey = 'blog_writer_gemini_api_key';
const _kPublishToken = 'blog_writer_publish_token';
const _kServerUrl = 'blog_writer_server_url';

enum BlogWriterStatus { idle, loading, success, error }

enum PublishStatus { idle, publishing, success, error }

class BlogWriterViewModel extends ChangeNotifier {
  BlogWriterViewModel({
    Dio? dio,
    FlutterSecureStorage? storage,
    BlogHistoryRepository? historyRepo,
    DropdownCacheRepository? dropdownCache,
  }) : _dio = dio ?? Dio(),
       _storage = storage ?? const FlutterSecureStorage(),
       _historyRepo = historyRepo ?? BlogHistoryRepository(),
       _dropdownCache = dropdownCache ?? DropdownCacheRepository();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final BlogHistoryRepository _historyRepo;
  final DropdownCacheRepository _dropdownCache;

  static const _publishUrl =
      'https://api.preptm.com/api/translation/article/AddUpdate';
  static const _articleTypeUrl =
      'https://api.preptm.com/api/dropdown/AllDropDown/GetDDLLookupDataByLookupTypeIdAndLookupType';
  static const _tagsUrl =
      'https://api.preptm.com/api/dropdown/AllDropDown/AllDropDown?keys=ddlBlockType%2CddlGroup';

  // ---- Gemini ----
  static const _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const _geminiModels = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];

  // ---- Settings ----
  String _geminiApiKey = '';
  String _publishToken = '';
  String _serverUrl = 'http://localhost:8000';
  bool _isSettingsOpen = false;
  bool _showGeminiKey = false;
  bool _showPublishToken = false;
  bool _keysSaved = false;

  // ---- Dropdowns ----
  List<DropdownItem> _articleTypes = [];
  List<DropdownItem> _allTags = [];
  bool _isLoadingDropdowns = false;
  String? _dropdownError;

  // ---- Input ----
  String _url = '';
  String _mode = 'gemini';
  int? _selectedArticleTypeId;
  Set<int> _selectedTagIds = {};

  // ---- Generation ----
  BlogWriterStatus _status = BlogWriterStatus.idle;
  BlogArticleData? _articleData;
  String? _errorMessage;

  // ---- Publish ----
  PublishStatus _publishStatus = PublishStatus.idle;
  String? _publishError;

  // ---- History ----
  List<BlogHistoryEntry> _history = [];
  bool _isHistoryOpen = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get geminiApiKey => _geminiApiKey;
  String get publishToken => _publishToken;
  String get serverUrl => _serverUrl;
  bool get isSettingsOpen => _isSettingsOpen;
  bool get showGeminiKey => _showGeminiKey;
  bool get showPublishToken => _showPublishToken;
  bool get keysSaved => _keysSaved;

  List<DropdownItem> get articleTypes => _articleTypes;
  List<DropdownItem> get allTags => _allTags;
  bool get isLoadingDropdowns => _isLoadingDropdowns;
  String? get dropdownError => _dropdownError;

  String get url => _url;
  String get mode => _mode;
  int? get selectedArticleTypeId => _selectedArticleTypeId;
  Set<int> get selectedTagIds => _selectedTagIds;

  BlogWriterStatus get status => _status;
  BlogArticleData? get articleData => _articleData;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == BlogWriterStatus.loading;
  bool get hasResult =>
      _status == BlogWriterStatus.success && _articleData != null;
  bool get hasError => _status == BlogWriterStatus.error;

  PublishStatus get publishStatus => _publishStatus;
  String? get publishError => _publishError;
  bool get isPublishing => _publishStatus == PublishStatus.publishing;
  bool get publishSuccess => _publishStatus == PublishStatus.success;

  bool get hasGeminiKey => _geminiApiKey.trim().isNotEmpty;
  bool get hasPublishToken => _publishToken.trim().isNotEmpty;

  List<BlogHistoryEntry> get history => _history;
  bool get isHistoryOpen => _isHistoryOpen;

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> loadStoredKeys() async {
    _geminiApiKey = await _storage.read(key: _kGeminiApiKey) ?? '';
    _publishToken = await _storage.read(key: _kPublishToken) ?? '';
    _serverUrl =
        await _storage.read(key: _kServerUrl) ?? 'http://localhost:8000';
    notifyListeners();
    // Load dropdowns from cache first, fetch from API only if empty
    await _loadDropdownsFromCache();
    if (_articleTypes.isEmpty && _allTags.isEmpty) {
      refreshDropdowns();
    }
    // Load blog history
    loadHistory();
  }

  Future<void> loadHistory() async {
    _history = await _historyRepo.getAll();
    notifyListeners();
  }

  void openHistory() {
    _isHistoryOpen = true;
    notifyListeners();
  }

  void closeHistory() {
    _isHistoryOpen = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  void openSettings() {
    _isSettingsOpen = true;
    _keysSaved = false;
    notifyListeners();
  }

  void closeSettings() {
    _isSettingsOpen = false;
    notifyListeners();
  }

  void toggleGeminiKeyVisibility() {
    _showGeminiKey = !_showGeminiKey;
    notifyListeners();
  }

  void togglePublishTokenVisibility() {
    _showPublishToken = !_showPublishToken;
    notifyListeners();
  }

  void updateGeminiApiKey(String v) {
    _geminiApiKey = v;
    _keysSaved = false;
    notifyListeners();
  }

  void updatePublishToken(String v) {
    _publishToken = v;
    _keysSaved = false;
    notifyListeners();
  }

  void updateServerUrl(String v) {
    _serverUrl = v;
    _keysSaved = false;
    notifyListeners();
  }

  Future<void> saveKeys() async {
    await _storage.write(key: _kGeminiApiKey, value: _geminiApiKey.trim());
    await _storage.write(key: _kPublishToken, value: _publishToken.trim());
    await _storage.write(key: _kServerUrl, value: _serverUrl.trim());
    _keysSaved = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  void updateUrl(String v) {
    _url = v;
    if (_status == BlogWriterStatus.error) {
      _status = BlogWriterStatus.idle;
      _errorMessage = null;
    }
    notifyListeners();
  }

  void updateMode(String v) {
    _mode = v;
    notifyListeners();
  }

  void selectArticleType(int? id) {
    _selectedArticleTypeId = id;
    notifyListeners();
  }

  void toggleTag(int tagId) {
    if (_selectedTagIds.contains(tagId)) {
      _selectedTagIds = Set.from(_selectedTagIds)..remove(tagId);
    } else {
      _selectedTagIds = Set.from(_selectedTagIds)..add(tagId);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Dropdowns — cache first, API on refresh
  // ---------------------------------------------------------------------------

  /// Load from local cache (instant, no network).
  Future<void> _loadDropdownsFromCache() async {
    _articleTypes = await _dropdownCache.getArticleTypes();
    _allTags = await _dropdownCache.getTags();
    notifyListeners();
  }

  /// Fetch from API, update cache, and refresh UI. Called on explicit refresh.
  Future<void> refreshDropdowns() async {
    _isLoadingDropdowns = true;
    _dropdownError = null;
    notifyListeners();

    try {
      final authHeaders = {
        if (_publishToken.trim().isNotEmpty)
          'Authorization': _publishToken.trim(),
        'origin': 'https://admin.preptm.com',
      };

      final response = await _dio.get<dynamic>(
        _articleTypeUrl,
        queryParameters: {
          'SlugUrl': 'article-type',
          'LookupType': '',
          'LookupTypeId': '',
        },
        options: Options(
          headers: authHeaders,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response2 = await _dio.get<dynamic>(
        _tagsUrl,
        options: Options(
          headers: authHeaders,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Parse article types
      final atRaw = response.data;
      final atBody = atRaw is Map<String, dynamic> ? atRaw : null;
      if (atBody != null && atBody['isSuccess'] == true) {
        final list = (atBody['data'] as Map<String, dynamic>?)?['article-type'];
        if (list is List) {
          _articleTypes = list
              .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
              .toList();
          await _dropdownCache.saveArticleTypes(_articleTypes);
        }
      }

      // Parse tags
      final tagRaw = response2.data;
      final tagBody = tagRaw is Map<String, dynamic> ? tagRaw : null;
      if (tagBody != null && tagBody['isSuccess'] == true) {
        final list = (tagBody['data'] as Map<String, dynamic>?)?['ddlGroup'];
        if (list is List) {
          _allTags = list
              .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
              .toList();
          await _dropdownCache.saveTags(_allTags);
        }
      }

      _isLoadingDropdowns = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoadingDropdowns = false;
      _dropdownError = 'Failed to sync dropdowns: ${e.message ?? e.type.name}';
      notifyListeners();
    } catch (e) {
      _isLoadingDropdowns = false;
      _dropdownError = 'Failed to sync dropdowns: $e';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Generate blog
  // ---------------------------------------------------------------------------

  Future<void> generateBlog() async {
    if (isLoading) return;

    final trimmedUrl = _url.trim();
    if (trimmedUrl.isEmpty) {
      _setError('Please enter a blog URL.');
      return;
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      _setError('Please enter a valid URL (e.g. https://example.com/blog).');
      return;
    }

    if (_mode == 'gemini' && !hasGeminiKey) {
      _setError('Gemini mode requires an API key. Open Settings to add one.');
      return;
    }

    // Duplicate URL check
    final isDuplicate = await _historyRepo.urlExists(trimmedUrl);
    if (isDuplicate) {
      _setError(
        'This URL has already been used to generate a blog. Check the History tab.',
      );
      return;
    }

    _status = BlogWriterStatus.loading;
    _errorMessage = null;
    _articleData = null;
    _publishStatus = PublishStatus.idle;
    _publishError = null;
    notifyListeners();

    try {
      if (_mode == 'gemini') {
        await _generateWithGemini(trimmedUrl);
      } else {
        await _generateWithPython(trimmedUrl);
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Gemini direct — with model fallback
  // ---------------------------------------------------------------------------

  Future<void> _generateWithGemini(String blogUrl) async {
    // Step 1: Scrape the blog URL content
    print('[BlogWriter] Scraping URL: $blogUrl');
    final scraped = await _scrapeUrl(blogUrl);
    if (scraped == null || scraped.length < 100) {
      _setError('Could not extract enough content from the URL.');
      return;
    }
    print('[BlogWriter] Scraped ${scraped.length} chars');

    // Step 2: Build prompt
    final prompt = _buildBlogPrompt(scraped, blogUrl);

    // Step 3: Try Gemini models in order
    final apiKey = _geminiApiKey.trim();
    Object? lastError;

    for (var i = 0; i < _geminiModels.length; i++) {
      final model = _geminiModels[i];
      final url = '$_geminiBaseUrl/$model:generateContent?key=$apiKey';

      print(
        '[BlogWriter] Trying Gemini model ${i + 1}/${_geminiModels.length}: $model',
      );

      try {
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
            'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 8192},
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (s) => s != null && s < 500,
            receiveTimeout: const Duration(seconds: 120),
          ),
        );

        if (response.statusCode != 200) {
          print(
            '[BlogWriter] Model $model failed with HTTP ${response.statusCode}',
          );
          lastError = 'Model $model: HTTP ${response.statusCode}';
          continue;
        }

        final body = response.data;
        if (body == null) {
          lastError = 'Model $model: empty response';
          continue;
        }

        // Extract text from Gemini response
        final candidates = body['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          lastError = 'Model $model: no candidates';
          continue;
        }

        final parts =
            (candidates.first as Map<String, dynamic>)['content']?['parts']
                as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          lastError = 'Model $model: no parts';
          continue;
        }

        final text = (parts.first as Map<String, dynamic>)['text'] as String?;
        if (text == null || text.trim().isEmpty) {
          lastError = 'Model $model: empty text';
          continue;
        }

        print('[BlogWriter] Model $model succeeded, parsing response...');

        // Step 4: Parse the JSON response
        final article = _parseGeminiResponse(text.trim());
        if (article != null) {
          _articleData = article;
          _status = BlogWriterStatus.success;
          await _saveHistoryEntry(blogUrl);
          notifyListeners();
          return;
        }

        lastError = 'Model $model: could not parse response into article data';
        continue;
      } on DioException catch (e) {
        print('[BlogWriter] Model $model DioException: ${e.message}');
        lastError = 'Model $model: ${e.message ?? e.type.name}';
        continue;
      } catch (e) {
        print('[BlogWriter] Model $model error: $e');
        lastError = e;
        continue;
      }
    }

    // All models failed
    _setError('All Gemini models failed. Last error: $lastError');
  }

  /// Fetch the blog page HTML and strip tags to get plain text.
  Future<String?> _scrapeUrl(String url) async {
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
          validateStatus: (s) => s != null && s < 400,
        ),
      );

      final html = response.data;
      if (html == null || html.isEmpty) return null;

      // Strip script, style, nav, footer, header tags and their content
      var text = html
          .replaceAll(
            RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<nav[^>]*>[\s\S]*?</nav>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<footer[^>]*>[\s\S]*?</footer>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<header[^>]*>[\s\S]*?</header>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<aside[^>]*>[\s\S]*?</aside>', caseSensitive: false),
            '',
          );

      // Strip all remaining HTML tags
      text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');

      // Decode common HTML entities
      text = text
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&nbsp;', ' ');

      // Collapse whitespace
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Limit to ~15000 chars to stay within Gemini context
      if (text.length > 15000) text = text.substring(0, 15000);

      return text;
    } catch (e) {
      print('[BlogWriter] Scrape error: $e');
      return null;
    }
  }

  /// Build the Gemini prompt for blog rewriting.
  String _buildBlogPrompt(String scrapedText, String sourceUrl) {
    final categoryId = _selectedArticleTypeId ?? 0;
    final tagIds = _selectedTagIds.toList();

    return '''You are a professional bilingual (English + Hindi) blog writer and SEO expert.

I will give you scraped text from a blog URL. Rewrite it into a fresh, original, SEO-friendly blog post in BOTH English and Hindi.

Source URL: $sourceUrl

Scraped content:
$scrapedText

You MUST respond with ONLY valid JSON (no markdown fences, no extra text). Use this exact structure:

{
"title": "English blog title",
"titleHindi": "Hindi blog title",
"articleType": $categoryId,
"slugUrl": "english-title-as-slug",
"keywords": "keyword1, keyword2, keyword3",
"keywordHindi": "hindi keyword1, hindi keyword2",
"description": "<p>Full rewritten English blog as HTML with <p> and <h2> tags</p>",
"descriptionHindi": "<p>Full rewritten Hindi blog as HTML with <p> and <h2> tags</p>",
"summary": "2-3 sentence English summary",
"summaryHindi": "2-3 sentence Hindi summary",
"thumbnail": "",
"thumbnailCredit": null,
"articleFaqsDTOs": [
{
"id": 0,
"que": "English question about a key topic from the blog",
"ans": "English answer explaining the topic clearly",
"queHindi": "Same question in Hindi",
"ansHindi": "Same answer in Hindi",
"isUpdate": false
}
],
"articleTagsDTOs": $tagIds,
"descriptionJson": "{}",
"descriptionJsonHindi": "{}"
}

Rules:

-The English description must be well-structured HTML with <h2> headings and <p> paragraphs
-The Hindi description must be a faithful translation, also in HTML format
-keywords should be 5-8 comma-separated relevant SEO keywords
-slugUrl must be lowercase, hyphen-separated, no special characters
-summary should be concise, 2-3 sentences
-Respond with ONLY the JSON object, nothing else
-Change Website name, if getting other same just replace with PreptTM
-Total word limit for description and descriptionHindi combined should not exceed 800+ words
-Generate 3-5 FAQs in articleFaqsDTOs based on the blog content. Each FAQ must have que/ans in English and queHindi/ansHindi in Hindi. Use id:0 and isUpdate:false for all. If the content has no meaningful FAQ topics, return an empty array

Additional Rules:

-Blog content must feel like written by a human, natural and engaging (avoid robotic tone)
-Completely rewrite and modify the content; do NOT keep sentences or structure same as source
-Keep language simple and easy to understand for beginners
-Use short paragraphs and clear headings for better readability
-Add at least one HTML table wherever helpful. Tables MUST be wrapped like: <div class="editor-table"><table><tbody><tr><td>cell</td></tr></tbody></table></div>
-Maintain proper flow: introduction → explanation → examples → conclusion
-Hindi content should be natural and conversational
-Use some common English words in Hindi (like app, online, process) where appropriate
-Avoid complex or heavy Hindi vocabulary
-Do not translate word-to-word; make Hindi version feel native and smooth
-Ensure content is useful, practical, and user-friendly
-Optimize for SEO but avoid keyword stuffing
-Add apply and view result, notification download or official website link if original govt. url found in content, each govt website contain .gov , .nic.in, .org domains, if found any of these domain in content then add link with anchor tag in description and descriptionHindi with text "Apply here" for application link and "View result" for result link, "Download here" for notification download link and "Official website" for official website link, also add same links in FAQ answer if relevant.


''';
  }

  /// Parse the Gemini text response into BlogArticleData.
  BlogArticleData? _parseGeminiResponse(String rawText) {
    try {
      // Strip markdown code fences if Gemini added them
      var text = rawText
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();

      final json = jsonDecode(text) as Map<String, dynamic>;
      return BlogArticleData.fromJson(json);
    } catch (e) {
      print('[BlogWriter] Failed to parse Gemini JSON: $e');
      print(
        '[BlogWriter] Raw text: ${rawText.substring(0, rawText.length.clamp(0, 500))}',
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Python server (local mode)
  // ---------------------------------------------------------------------------

  Future<void> _generateWithPython(String trimmedUrl) async {
    try {
      final request = ProcessBlogRequest(
        url: trimmedUrl,
        mode: _mode,
        categoryId: _selectedArticleTypeId ?? 0,
        tags: _selectedTagIds.toList(),
      );

      final baseUrl = _serverUrl.trim().replaceAll(RegExp(r'/+$'), '');

      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/process-blog',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final body = response.data;
      if (body == null) {
        _setError('Empty response from the blog API.');
        return;
      }

      final parsed = ProcessBlogResponse.fromJson(body);

      if (!parsed.success) {
        _setError(parsed.message ?? 'Blog generation failed.');
        return;
      }

      if (parsed.data == null) {
        _setError('API returned success but no data.');
        return;
      }

      _articleData = parsed.data;
      _status = BlogWriterStatus.success;
      await _saveHistoryEntry(trimmedUrl);
      notifyListeners();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _setError(
          'Could not connect to the blog API at $_serverUrl. '
          'Make sure the Python server is running.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        _setError(
          'Request timed out. AI processing can take 30-120 seconds. Try again.',
        );
      } else {
        _setError('Network error: ${e.message ?? e.type.name}');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Inline editing of article fields
  // ---------------------------------------------------------------------------

  void updateArticleTitle(String v) {
    _articleData = _articleData?.copyWith(title: v);
    notifyListeners();
  }

  void updateArticleTitleHindi(String v) {
    _articleData = _articleData?.copyWith(titleHindi: v);
    notifyListeners();
  }

  void updateArticleDescription(String v) {
    _articleData = _articleData?.copyWith(description: v);
    notifyListeners();
  }

  void updateArticleDescriptionHindi(String v) {
    _articleData = _articleData?.copyWith(descriptionHindi: v);
    notifyListeners();
  }

  void updateArticleSummary(String v) {
    _articleData = _articleData?.copyWith(summary: v);
    notifyListeners();
  }

  void updateArticleSummaryHindi(String v) {
    _articleData = _articleData?.copyWith(summaryHindi: v);
    notifyListeners();
  }

  void updateArticleKeywords(String v) {
    _articleData = _articleData?.copyWith(keywords: v);
    notifyListeners();
  }

  void updateArticleKeywordHindi(String v) {
    _articleData = _articleData?.copyWith(keywordHindi: v);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Publish
  // ---------------------------------------------------------------------------

  Future<void> publishBlog() async {
    if (isPublishing || _articleData == null) return;

    if (!hasPublishToken) {
      _publishError = 'No publish token set. Open Settings to add one.';
      notifyListeners();
      return;
    }

    _publishStatus = PublishStatus.publishing;
    _publishError = null;
    notifyListeners();

    var request = _articleData!.toPublishJson();

    print("request --- $request");

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _publishUrl,
        data: request,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_publishToken.trim()}',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;

      if (response.statusCode == 401) {
        _publishError = 'Unauthorized. Check your publish token in settings.';
        _publishStatus = PublishStatus.error;
        notifyListeners();
        return;
      }

      if (body != null && body['isSuccess'] == true) {
        _publishStatus = PublishStatus.success;
        await _historyRepo.updateStatus(_url.trim(), 'published');
        _history = await _historyRepo.getAll();
        notifyListeners();
        return;
      }

      _publishError =
          body?['message'] as String? ??
          'Publish failed (status ${response.statusCode}).';
      _publishStatus = PublishStatus.error;
      notifyListeners();
    } on DioException catch (e) {
      _publishError = 'Network error: ${e.message ?? e.type.name}';
      _publishStatus = PublishStatus.error;
      notifyListeners();
    } catch (e) {
      _publishError = 'Publish failed: $e';
      _publishStatus = PublishStatus.error;
      notifyListeners();
    }
  }

  void clearPublishState() {
    _publishStatus = PublishStatus.idle;
    _publishError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  void clearResult() {
    _articleData = null;
    _status = BlogWriterStatus.idle;
    _errorMessage = null;
    _publishStatus = PublishStatus.idle;
    _publishError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _setError(String msg) {
    _status = BlogWriterStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // History helpers
  // ---------------------------------------------------------------------------

  Future<void> _saveHistoryEntry(String url) async {
    final entry = BlogHistoryEntry(
      url: url,
      slugUrl: _articleData?.slugUrl ?? '',
      title: _articleData?.title ?? '',
      createdAt: DateTime.now(),
      status: 'generated',
    );
    await _historyRepo.addEntry(entry);
    _history = await _historyRepo.getAll();
  }
}

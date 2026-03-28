import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ---------------------------------------------------------------------------
// Storage key
// ---------------------------------------------------------------------------

const _kBlogWriterTokenKey = 'blog_writer_api_token';

// ---------------------------------------------------------------------------
// Generation status enum
// ---------------------------------------------------------------------------

enum BlogWriterStatus { idle, loading, success, error }

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

/// ViewModel for the Blog Writer (URL-to-Blog) tool.
///
/// Responsibilities:
///   - Persist and load the API bearer token via [FlutterSecureStorage].
///   - Accept a source URL from the user.
///   - POST to the Python API and surface the returned blog text.
///   - Expose clean state for the UI: loading flag, error message, result text.
class BlogWriterViewModel extends ChangeNotifier {
  BlogWriterViewModel({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  // ---- Token ----
  String _apiToken = '';
  bool _showToken = false;
  bool _tokenSaved = false;

  // ---- Settings panel ----
  bool _isSettingsOpen = false;

  // ---- Input ----
  String _url = '';

  // ---- Generation state ----
  BlogWriterStatus _status = BlogWriterStatus.idle;
  String? _blogContent;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get apiToken => _apiToken;
  bool get showToken => _showToken;
  bool get tokenSaved => _tokenSaved;
  bool get isSettingsOpen => _isSettingsOpen;

  String get url => _url;

  BlogWriterStatus get status => _status;
  String? get blogContent => _blogContent;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == BlogWriterStatus.loading;
  bool get hasResult => _status == BlogWriterStatus.success && _blogContent != null;
  bool get hasError => _status == BlogWriterStatus.error;

  bool get hasToken => _apiToken.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Load the persisted API token from secure storage.
  Future<void> loadStoredToken() async {
    _apiToken = await _storage.read(key: _kBlogWriterTokenKey) ?? '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Settings mutations
  // ---------------------------------------------------------------------------

  void openSettings() {
    _isSettingsOpen = true;
    _tokenSaved = false;
    notifyListeners();
  }

  void closeSettings() {
    _isSettingsOpen = false;
    notifyListeners();
  }

  void toggleTokenVisibility() {
    _showToken = !_showToken;
    notifyListeners();
  }

  void updateApiToken(String value) {
    _apiToken = value;
    _tokenSaved = false;
    notifyListeners();
  }

  /// Persist the current token to secure storage.
  Future<void> saveToken() async {
    await _storage.write(key: _kBlogWriterTokenKey, value: _apiToken.trim());
    _tokenSaved = true;
    notifyListeners();
  }

  /// Clear the persisted token and reset local state.
  Future<void> clearToken() async {
    await _storage.delete(key: _kBlogWriterTokenKey);
    _apiToken = '';
    _tokenSaved = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Input mutations
  // ---------------------------------------------------------------------------

  void updateUrl(String value) {
    _url = value;
    if (_hasError) _clearError();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Blog generation
  // ---------------------------------------------------------------------------

  /// POST the URL to the Python backend and store the returned blog content.
  Future<void> generateBlog() async {
    if (isLoading) return;

    final trimmedUrl = _url.trim();

    if (trimmedUrl.isEmpty) {
      _setError('Please enter a URL before generating.');
      return;
    }

    if (!_isValidUrl(trimmedUrl)) {
      _setError('Please enter a valid URL (e.g. https://example.com/article).');
      return;
    }

    if (!hasToken) {
      _setError(
        'No API token set. Tap the settings icon to add your token.',
      );
      return;
    }

    _status = BlogWriterStatus.loading;
    _errorMessage = null;
    _blogContent = null;
    notifyListeners();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'http://localhost:8000/api/blog/generate',
        data: {'url': trimmedUrl},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_apiToken.trim()}',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;
      final httpStatus = response.statusCode ?? 0;

      if (httpStatus == 401 || httpStatus == 403) {
        _setError('Authentication failed. Check your API token in settings.');
        return;
      }

      if (httpStatus >= 400) {
        final detail = body?['detail'] as String? ??
            body?['message'] as String? ??
            'Request failed with status $httpStatus.';
        _setError(detail);
        return;
      }

      if (body == null) {
        _setError('Empty response from the blog generation API.');
        return;
      }

      // Accept either a "content" or "blog" key from the API.
      final content = body['content'] as String? ??
          body['blog'] as String? ??
          body['result'] as String?;

      if (content == null || content.trim().isEmpty) {
        _setError('The API returned an empty blog. Please try a different URL.');
        return;
      }

      _blogContent = content;
      _status = BlogWriterStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _setError(
          'Could not connect to the blog API at localhost:8000. '
          'Make sure the Python server is running.',
        );
      } else {
        _setError('Network error: ${e.message ?? e.type.name}');
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  /// Reset back to the input form, clearing any result or error.
  void clearResult() {
    _blogContent = null;
    _status = BlogWriterStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool get _hasError => _status == BlogWriterStatus.error;

  void _clearError() {
    _status = BlogWriterStatus.idle;
    _errorMessage = null;
  }

  void _setError(String message) {
    _status = BlogWriterStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/blog/blog_post.dart';
import 'services/blog_ai_service.dart';

// ---------------------------------------------------------------------------
// Storage keys
// ---------------------------------------------------------------------------

const _kOpenAiKey = 'blog_gen_openai_api_key';
const _kGeminiKey = 'blog_gen_gemini_api_key';
const _kProviderKey = 'blog_gen_selected_provider';
const _kAuthTokenKey = 'blog_gen_publish_auth_token';
const _kOllamaModelKey = 'blog_gen_ollama_model';
const _kOllamaUrlKey = 'blog_gen_ollama_base_url';

/// ViewModel for the AI Blog Generator tool.
///
/// Owns all mutable state: API keys, provider selection, topic inputs,
/// generation lifecycle, and the produced [BlogPost].
class AiBlogGeneratorViewModel extends ChangeNotifier {
  AiBlogGeneratorViewModel({
    BlogAiService? service,
    FlutterSecureStorage? storage,
  }) : _service = service ?? BlogAiService(),
       _storage = storage ?? const FlutterSecureStorage();

  final BlogAiService _service;
  final FlutterSecureStorage _storage;

  // ---- API keys ----
  String _openAiApiKey = '';
  String _geminiApiKey = '';
  String _authToken = '';

  // ---- Ollama settings ----
  String _ollamaModel = 'llama3.1';
  String _ollamaBaseUrl = 'http://localhost:11434';

  // ---- Provider selection ----
  ApiProvider _selectedProvider = ApiProvider.openai;

  // ---- Input fields ----
  String _topic = '';
  BlogTone _tone = BlogTone.professional;
  int _targetWordCount = 800;

  // ---- Generation state ----
  BlogGenerationStatus _status = BlogGenerationStatus.idle;
  BlogPost? _blogPost;
  String? _errorMessage;

  // ---- Publish state ----
  bool _isPublishing = false;
  bool _publishSuccess = false;
  String? _publishError;

  // ---- Settings panel visibility ----
  bool _isSettingsOpen = false;

  // ---- Key visibility (for password fields) ----
  bool _showOpenAiKey = false;
  bool _showGeminiKey = false;
  bool _showAuthToken = false;

  // ---- Key-save feedback ----
  bool _keysSaved = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get openAiApiKey => _openAiApiKey;
  String get geminiApiKey => _geminiApiKey;
  String get authToken => _authToken;
  String get ollamaModel => _ollamaModel;
  String get ollamaBaseUrl => _ollamaBaseUrl;
  ApiProvider get selectedProvider => _selectedProvider;

  String get topic => _topic;
  BlogTone get tone => _tone;
  int get targetWordCount => _targetWordCount;

  BlogGenerationStatus get status => _status;
  BlogPost? get blogPost => _blogPost;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == BlogGenerationStatus.loading;
  bool get hasResult =>
      _status == BlogGenerationStatus.success && _blogPost != null;
  bool get hasError => _status == BlogGenerationStatus.error;

  bool get isPublishing => _isPublishing;
  bool get publishSuccess => _publishSuccess;
  String? get publishError => _publishError;

  bool get isSettingsOpen => _isSettingsOpen;
  bool get showOpenAiKey => _showOpenAiKey;
  bool get showGeminiKey => _showGeminiKey;
  bool get showAuthToken => _showAuthToken;
  bool get keysSaved => _keysSaved;

  /// Returns true when the active provider has a non-empty API key configured.
  bool get hasValidKey {
    switch (_selectedProvider) {
      case ApiProvider.openai:
        return _openAiApiKey.trim().isNotEmpty;
      case ApiProvider.gemini:
        return _geminiApiKey.trim().isNotEmpty;
      case ApiProvider.ollama:
        return _ollamaModel.trim().isNotEmpty;
    }
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Load stored API keys and provider preference from secure storage.
  Future<void> loadStoredKeys() async {
    _openAiApiKey = await _storage.read(key: _kOpenAiKey) ?? '';
    _geminiApiKey = await _storage.read(key: _kGeminiKey) ?? '';
    _authToken = await _storage.read(key: _kAuthTokenKey) ?? '';
    _ollamaModel = await _storage.read(key: _kOllamaModelKey) ?? 'llama3.1';
    _ollamaBaseUrl =
        await _storage.read(key: _kOllamaUrlKey) ?? 'http://localhost:11434';
    final storedProvider = await _storage.read(key: _kProviderKey);
    if (storedProvider == ApiProvider.gemini.name) {
      _selectedProvider = ApiProvider.gemini;
    } else if (storedProvider == ApiProvider.ollama.name) {
      _selectedProvider = ApiProvider.ollama;
    } else {
      _selectedProvider = ApiProvider.openai;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Settings mutations
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

  void toggleOpenAiKeyVisibility() {
    _showOpenAiKey = !_showOpenAiKey;
    notifyListeners();
  }

  void toggleGeminiKeyVisibility() {
    _showGeminiKey = !_showGeminiKey;
    notifyListeners();
  }

  void toggleAuthTokenVisibility() {
    _showAuthToken = !_showAuthToken;
    notifyListeners();
  }

  void updateOpenAiApiKey(String value) {
    _openAiApiKey = value;
    _keysSaved = false;
    notifyListeners();
  }

  void updateGeminiApiKey(String value) {
    _geminiApiKey = value;
    _keysSaved = false;
    notifyListeners();
  }

  void updateAuthToken(String value) {
    _authToken = value;
    _keysSaved = false;
    notifyListeners();
  }

  void updateOllamaModel(String value) {
    _ollamaModel = value;
    _keysSaved = false;
    notifyListeners();
  }

  void updateOllamaBaseUrl(String value) {
    _ollamaBaseUrl = value;
    _keysSaved = false;
    notifyListeners();
  }

  void selectProvider(ApiProvider provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  /// Persist current API keys and provider to secure storage.
  Future<void> saveKeys() async {
    await _storage.write(key: _kOpenAiKey, value: _openAiApiKey.trim());
    await _storage.write(key: _kGeminiKey, value: _geminiApiKey.trim());
    await _storage.write(key: _kAuthTokenKey, value: _authToken.trim());
    await _storage.write(key: _kOllamaModelKey, value: _ollamaModel.trim());
    await _storage.write(key: _kOllamaUrlKey, value: _ollamaBaseUrl.trim());
    await _storage.write(key: _kProviderKey, value: _selectedProvider.name);
    _keysSaved = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Input mutations
  // ---------------------------------------------------------------------------

  void updateTopic(String value) {
    _topic = value;
    notifyListeners();
  }

  void updateTone(BlogTone tone) {
    _tone = tone;
    notifyListeners();
  }

  void updateTargetWordCount(int count) {
    _targetWordCount = count;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Blog generation
  // ---------------------------------------------------------------------------

  Future<void> generateBlog() async {
    if (isLoading) return;

    final trimmedTopic = _topic.trim();
    if (trimmedTopic.isEmpty) {
      _setError('Please enter a blog topic before generating.');
      return;
    }

    if (!hasValidKey) {
      _setError(
        'No API key set for ${_selectedProvider.displayName}. '
        'Open Settings to add your key.',
      );
      return;
    }

    _status = BlogGenerationStatus.loading;
    _errorMessage = null;
    _blogPost = null;
    notifyListeners();

    try {
      final post = await _service.generateBlog(
        topic: trimmedTopic,
        tone: _tone,
        targetWordCount: _targetWordCount,
        provider: _selectedProvider,
        apiKey: _activeApiKey,
        ollamaModel: _ollamaModel.trim(),
        ollamaBaseUrl: _ollamaBaseUrl.trim(),
      );

      _blogPost = post;
      _status = BlogGenerationStatus.success;
      notifyListeners();
    } on BlogAiServiceException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    }
  }

  /// Clear the current result and go back to the input form.
  void clearResult() {
    _blogPost = null;
    _status = BlogGenerationStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update a section's content inline (for in-place editing).
  void updateSectionContent(int index, String newContent) {
    if (_blogPost == null) return;
    final updatedSections = List<BlogSection>.from(_blogPost!.sections);
    updatedSections[index] = updatedSections[index].copyWith(
      content: newContent,
    );
    _blogPost = _blogPost!.copyWith(sections: updatedSections);
    notifyListeners();
  }

  /// Update a section heading inline.
  void updateSectionHeading(int index, String newHeading) {
    if (_blogPost == null) return;
    final updatedSections = List<BlogSection>.from(_blogPost!.sections);
    updatedSections[index] = updatedSections[index].copyWith(
      heading: newHeading,
    );
    _blogPost = _blogPost!.copyWith(sections: updatedSections);
    notifyListeners();
  }

  /// Update the blog title inline.
  void updateTitle(String newTitle) {
    if (_blogPost == null) return;
    _blogPost = _blogPost!.copyWith(title: newTitle);
    notifyListeners();
  }

  /// Update the introduction inline.
  void updateIntroduction(String newIntro) {
    if (_blogPost == null) return;
    _blogPost = _blogPost!.copyWith(introduction: newIntro);
    notifyListeners();
  }

  /// Update the conclusion inline.
  void updateConclusion(String newConclusion) {
    if (_blogPost == null) return;
    _blogPost = _blogPost!.copyWith(conclusion: newConclusion);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Publish blog to API
  // ---------------------------------------------------------------------------

  /// Translates blog to Hindi, builds the JSON payload, and publishes to the API.
  Future<void> publishBlog() async {
    if (_isPublishing) return;
    if (_blogPost == null) return;

    if (_authToken.trim().isEmpty) {
      _publishError =
          'No auth token set. Open Settings to add your publish auth token.';
      notifyListeners();
      return;
    }

    if (!hasValidKey) {
      _publishError = 'No AI API key set. Needed for Hindi translation.';
      notifyListeners();
      return;
    }

    _isPublishing = true;
    _publishSuccess = false;
    _publishError = null;
    notifyListeners();

    try {
      // Step 1: Translate to Hindi using the selected AI provider
      final hindi = await _service.translateToHindi(
        post: _blogPost!,
        provider: _selectedProvider,
        apiKey: _activeApiKey,
        ollamaModel: _ollamaModel.trim(),
        ollamaBaseUrl: _ollamaBaseUrl.trim(),
      );

      // Step 2: Publish to the API
      await _service.publishBlog(
        post: _blogPost!,
        hindi: hindi,
        authToken: _authToken.trim(),
      );

      _isPublishing = false;
      _publishSuccess = true;
      notifyListeners();
    } on BlogAiServiceException catch (e) {
      _isPublishing = false;
      _publishError = e.message;
      notifyListeners();
    } catch (e) {
      _isPublishing = false;
      _publishError = 'Failed to publish: $e';
      notifyListeners();
    }
  }

  /// Reset publish state feedback.
  void clearPublishState() {
    _publishSuccess = false;
    _publishError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns the API key for the currently selected provider (empty for Ollama).
  String get _activeApiKey {
    switch (_selectedProvider) {
      case ApiProvider.openai:
        return _openAiApiKey.trim();
      case ApiProvider.gemini:
        return _geminiApiKey.trim();
      case ApiProvider.ollama:
        return '';
    }
  }

  void _setError(String message) {
    _status = BlogGenerationStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}

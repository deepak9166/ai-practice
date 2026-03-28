import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/downloads/video_download_state.dart';

class VideoDownloaderViewModel extends ChangeNotifier {
  VideoDownloaderViewModel({Dio? dio}) : _dio = dio ?? Dio() {
    _state = VideoDownloadState.initial();
  }

  final Dio _dio;

  late VideoDownloadState _state;

  VideoDownloadState get state => _state;

  void updateUrl(String url) {
    _state = _state.copyWith(url: url, errorMessage: null);
    notifyListeners();
  }

  Future<void> addAndProcess() async {
    final raw = _state.url.trim();
    if (raw.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Please enter at least one video link.');
      notifyListeners();
      return;
    }

    final urls = _parseUrls(raw);
    if (urls.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Please enter at least one valid link.');
      notifyListeners();
      return;
    }

    // Build new tasks from parsed URLs
    final newTasks = <DownloadTask>[];
    for (final url in urls) {
      final platform = _detectPlatform(url);
      if (platform == null) {
        _state = _state.copyWith(
          errorMessage: 'Unsupported URL: $url\nOnly Instagram and Snapchat links are supported.',
        );
        notifyListeners();
        return;
      }
      newTasks.add(DownloadTask(url: url, platform: platform));
    }

    // Extend existing list, clear text field
    final updatedTasks = [..._state.tasks, ...newTasks];
    _state = _state.copyWith(url: '', tasks: updatedTasks, errorMessage: null);
    notifyListeners();

    // Start processing if not already running
    if (!_state.isProcessing) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _state = _state.copyWith(isProcessing: true);
    notifyListeners();

    while (true) {
      final nextIndex = _state.tasks.indexWhere((t) => t.isPending);
      if (nextIndex == -1) break;

      // Mark as in-progress
      _updateTask(nextIndex, _state.tasks[nextIndex].copyWith(status: TaskStatus.inProgress));

      try {
        final task = _state.tasks[nextIndex];
        String? resultUrl;

        if (task.platform == VideoPlatform.instagram) {
          resultUrl = await _downloadInstagramViaApi(task.url);
        } else if (task.platform == VideoPlatform.snapchat) {
          resultUrl = await _downloadSnapchatViaApi(task.url);
        }

        _updateTask(
          nextIndex,
          _state.tasks[nextIndex].copyWith(
            status: TaskStatus.completed,
            resultUrl: resultUrl,
          ),
        );
      } catch (e) {
        _updateTask(
          nextIndex,
          _state.tasks[nextIndex].copyWith(
            status: TaskStatus.failed,
            error: e.toString(),
          ),
        );
      }
    }

    _state = _state.copyWith(isProcessing: false);
    notifyListeners();
  }

  void clearCompleted() {
    final remaining = _state.tasks.where((t) => !t.isCompleted && !t.isFailed).toList();
    _state = _state.copyWith(tasks: remaining);
    notifyListeners();
  }

  /// Remove a pending task from the queue (before it starts uploading).
  void removeTask(int index) {
    if (index < 0 || index >= _state.tasks.length) return;
    if (!_state.tasks[index].isPending) return;

    final tasks = [..._state.tasks]..removeAt(index);
    _state = _state.copyWith(tasks: tasks);
    notifyListeners();
  }

  /// Retry a failed task — resets it to pending and re-starts the queue.
  Future<void> retryTask(int index) async {
    if (index < 0 || index >= _state.tasks.length) return;
    if (!_state.tasks[index].isFailed) return;

    _updateTask(
      index,
      DownloadTask(
        url: _state.tasks[index].url,
        platform: _state.tasks[index].platform,
      ),
    );

    if (!_state.isProcessing) {
      await _processQueue();
    }
  }

  void _updateTask(int index, DownloadTask updated) {
    final tasks = [..._state.tasks];
    tasks[index] = updated;
    _state = _state.copyWith(tasks: tasks);
    notifyListeners();
  }

  VideoPlatform? _detectPlatform(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;

    final host = uri.host.toLowerCase();
    if (host.contains('instagram.com')) return VideoPlatform.instagram;
    if (host.contains('snapchat.com')) return VideoPlatform.snapchat;

    return null;
  }

  List<String> _parseUrls(String raw) {
    return raw
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<String> _downloadInstagramViaApi(String originalUrl) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'http://localhost:8000/instagram/download',
      data: {'url': originalUrl},
      options: Options(
        responseType: ResponseType.json,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final body = response.data;
    if (body == null) {
      throw Exception('Empty response from Instagram downloader API');
    }

    final videoUrl = body['video_url'] as String?;
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('API did not return a valid Instagram video URL.');
    }

    return videoUrl;
  }

  Future<String> _downloadSnapchatViaApi(String originalUrl) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'http://localhost:8000/snapchat/download',
      data: {'url': originalUrl},
      options: Options(
        responseType: ResponseType.json,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final body = response.data;
    if (body == null) {
      throw Exception('Empty response from Snapchat downloader API');
    }

    final videoUrl = body['video_url'] as String?;
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('API did not return a Snapchat video URL.');
    }

    return videoUrl;
  }
}

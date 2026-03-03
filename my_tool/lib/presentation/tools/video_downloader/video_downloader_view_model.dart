import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/downloads/video_download_state.dart';

class VideoDownloaderViewModel extends ChangeNotifier {
  VideoDownloaderViewModel({
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _state = VideoDownloadState.initial();
  }

  final Dio _dio;

  late VideoDownloadState _state;

  VideoDownloadState get state => _state;

  void updateUrl(String url) {
    _state = _state.copyWith(
      url: url.trim(),
      errorMessage: null,
    );
    notifyListeners();
  }

  Future<void> startDownload() async {
    if (_state.isInProgress) return;

    final url = _state.url.trim();
    if (url.isEmpty) {
      _setError('Please enter a video URL.');
      return;
    }

    if (!_looksLikeSupportedUrl(url)) {
      _setError('Please enter a valid video URL (e.g. Instagram, Snap).');
      return;
    }

    try {
      _state = _state.copyWith(
        status: DownloadStatus.inProgress,
        progress: 0,
        errorMessage: null,
        filePath: null,
      );
      notifyListeners();

      final directory = await _resolveDownloadDirectory();
      final fileName = _buildFileNameFromUrl(url);
      final targetFile = File('${directory.path}/$fileName');

      await _dio.download(
        url,
        targetFile.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final progress = received / total;
          _state = _state.copyWith(progress: progress);
          notifyListeners();
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      _state = _state.copyWith(
        status: DownloadStatus.completed,
        progress: 1,
        filePath: targetFile.path,
      );
      notifyListeners();
    } catch (error) {
      _setError(
        'Failed to download video. Check the link or your connection.',
      );
    }
  }

  void reset() {
    _state = VideoDownloadState.initial();
    notifyListeners();
  }

  bool _looksLikeSupportedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    final host = uri.host.toLowerCase();
    if (host.contains('instagram.com') || host.contains('snapchat.com')) {
      return true;
    }

    if (url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.webm') ||
        url.endsWith('.m4v')) {
      return true;
    }

    return false;
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return getApplicationDocumentsDirectory();
    }

    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return getApplicationDocumentsDirectory();
    }

    return getTemporaryDirectory();
  }

  String _buildFileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    String? lastSegment;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      lastSegment = uri.pathSegments.lastWhere(
        (segment) => segment.trim().isNotEmpty,
        orElse: () => '',
      );
    }

    if (lastSegment == null || lastSegment.isEmpty) {
      return 'video_$timestamp.mp4';
    }

    if (lastSegment.contains('.')) {
      return 'video_$timestamp-${lastSegment.replaceAll('/', '_')}';
    }

    return 'video_$timestamp-$lastSegment.mp4';
  }

  void _setError(String message) {
    _state = _state.copyWith(
      status: DownloadStatus.failed,
      progress: 0,
      errorMessage: message,
    );
    notifyListeners();
  }
}


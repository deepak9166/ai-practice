import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

  void updatePlatform(VideoPlatform platform) {
    _state = _state.copyWith(platform: platform, errorMessage: null);
    notifyListeners();
  }

  Future<void> startDownload() async {
    if (_state.isInProgress) return;

    final raw = _state.url.trim();
    if (raw.isEmpty) {
      _setError('Please enter at least one video link.');
      return;
    }

    final urls = _parseUrls(raw);
    if (urls.isEmpty) {
      _setError('Please enter at least one valid video link.');
      return;
    }

    if (!_allLookSupported(urls)) {
      _setError('Please enter Instagram, Snapchat or direct video links.');
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
      final totalCount = urls.length;

      String? lastFilePath;
      for (var i = 0; i < urls.length; i++) {
        final originalUrl = urls[i];

        if (_state.platform == VideoPlatform.instagram) {
          // Use backend API to download Instagram video
          final fileName = _buildFileNameFromUrl(originalUrl);
          final targetFile = File('${directory.path}/$fileName');

          await _downloadInstagramViaApi(
            originalUrl: originalUrl,
            targetFile: targetFile,
            index: i,
            totalCount: totalCount,
          );

          lastFilePath = targetFile.path;
          continue;
        }

        if (_state.platform == VideoPlatform.snapchat) {
          // Use backend API to download Snapchat video on the server
          await _downloadSnapchatViaApi(
            originalUrl: originalUrl,
            index: i,
            totalCount: totalCount,
          );

          lastFilePath = _state.filePath;
          continue;
        }

        final resolvedUrl = await _resolveDownloadUrl(
          originalUrl,
          _state.platform,
        );

        final fileName = _buildFileNameFromUrl(resolvedUrl);
        final targetFile = File('${directory.path}/$fileName');

        await _dio.download(
          resolvedUrl,
          targetFile.path,
          onReceiveProgress: (received, total) {
            if (total <= 0) return;
            final singleProgress = received / total;
            final overallProgress =
                (i / totalCount) + (singleProgress / totalCount);
            _state = _state.copyWith(progress: overallProgress);
            notifyListeners();
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 400,
          ),
        );

        lastFilePath = targetFile.path;
      }

      _state = _state.copyWith(
        status: DownloadStatus.completed,
        progress: 1,
        filePath:
            lastFilePath ??
            '${directory.path} (${urls.length} video(s) downloaded)',
      );
      notifyListeners();
    } catch (error) {
      print('Error downloading video: $error');
      _setError(
        'Failed to download video(s). Check the links or your connection.',
      );
    }
  }

  void reset() {
    _state = VideoDownloadState.initial();
    notifyListeners();
  }

  List<String> _parseUrls(String raw) {
    return raw
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _allLookSupported(List<String> urls) {
    return urls.every(_looksLikeSupportedUrl);
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

  Future<void> _downloadInstagramViaApi({
    required String originalUrl,
    required File targetFile,
    required int index,
    required int totalCount,
  }) async {
    // Call backend API to resolve the Instagram media and get metadata
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
    print('Response from Instagram downloader API: $body');
    if (body == null) {
      throw Exception('Empty response from Instagram downloader API');
    }

    final metadata = body['metadata'] as Map<String, dynamic>?;
    final isVideo = metadata?['is_video'] == true;
    final videoUrl = metadata?['video_url'] as String?;

    if (!isVideo || videoUrl == null || videoUrl.isEmpty) {
      throw Exception('API did not return a valid Instagram video URL.');
    }

    // Now download the actual video bytes from metadata.video_url
    await _dio.download(
      videoUrl,
      targetFile.path,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;
        final singleProgress = received / total;
        final overallProgress =
            (index / totalCount) + (singleProgress / totalCount);
        _state = _state.copyWith(progress: overallProgress);
        notifyListeners();
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
  }

  Future<void> _downloadSnapchatViaApi({
    required String originalUrl,
    required int index,
    required int totalCount,
  }) async {
    // Call backend API to download the Snapchat media and return metadata
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

    final filePath = body['file_path'] as String?;
    if (filePath == null || filePath.isEmpty) {
      throw Exception('API did not return a Snapchat file path.');
    }

    // Since the backend already downloaded the file, we just advance progress
    final overallProgress = (index + 1) / totalCount;
    _state = _state.copyWith(
      progress: overallProgress,
      filePath: filePath,
    );
    notifyListeners();
  }

  Future<String> _resolveDownloadUrl(
    String pageUrl,
    VideoPlatform platform,
  ) async {
    if (platform == VideoPlatform.direct) {
      return pageUrl;
    }

    // Fetch HTML page first, then try to extract a direct video URL
    final response = await _dio.get(
      pageUrl,
      options: Options(
        responseType: ResponseType.plain,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final html = response.data.toString();

    // Common pattern: <meta property="og:video" content="...mp4" />
    final ogVideoMeta = RegExp(
      '<meta[^>]+property=["\']og:video["\'][^>]+content=["\']([^"\']+)["\']',
      caseSensitive: false,
    ).firstMatch(html);

    if (ogVideoMeta != null) {
      return ogVideoMeta.group(1)!;
    }

    final ogVideoUrlMeta = RegExp(
      '<meta[^>]+property=["\']og:video:url["\'][^>]+content=["\']([^"\']+)["\']',
      caseSensitive: false,
    ).firstMatch(html);

    if (ogVideoUrlMeta != null) {
      return ogVideoUrlMeta.group(1)!;
    }

    // Fallback: first .mp4-like URL in the page
    final genericVideoUrl = RegExp(
      'https?://[^"\']+\\.(mp4|mov|webm|m4v)',
      caseSensitive: false,
    ).firstMatch(html);

    if (genericVideoUrl != null) {
      return genericVideoUrl.group(0)!;
    }

    throw Exception('Could not resolve direct video URL from page.');
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

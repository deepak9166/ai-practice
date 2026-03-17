enum DownloadStatus {
  idle,
  inProgress,
  completed,
  failed,
}

enum VideoPlatform {
  instagram,
  snapchat,
  direct,
}

class VideoDownloadState {
  const VideoDownloadState({
    required this.url,
    required this.status,
    required this.progress, // 0.0 - 1.0
    required this.errorMessage,
    required this.filePath,
    required this.platform,
    this.videoUrl,
  });

  factory VideoDownloadState.initial() => const VideoDownloadState(
        url: '',
        status: DownloadStatus.idle,
        progress: 0,
        errorMessage: null,
        filePath: null,
        platform: VideoPlatform.instagram,
        videoUrl: null,
      );

  /// Can be a single URL or multiple URLs separated by newlines.
  final String url;
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;
  final String? filePath;
  final VideoPlatform platform;

  /// Remote video URL returned by the API (for Instagram/Snapchat).
  final String? videoUrl;

  bool get isIdle => status == DownloadStatus.idle;

  bool get isInProgress => status == DownloadStatus.inProgress;

  bool get isCompleted => status == DownloadStatus.completed;

  bool get isFailed => status == DownloadStatus.failed;

  VideoDownloadState copyWith({
    String? url,
    DownloadStatus? status,
    double? progress,
    String? errorMessage,
    String? filePath,
    VideoPlatform? platform,
    String? videoUrl,
  }) {
    return VideoDownloadState(
      url: url ?? this.url,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      filePath: filePath ?? this.filePath,
      platform: platform ?? this.platform,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}


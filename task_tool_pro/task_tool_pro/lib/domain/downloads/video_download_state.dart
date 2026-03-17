enum TaskStatus {
  pending,
  inProgress,
  completed,
  failed,
}

enum VideoPlatform {
  instagram,
  snapchat,
  direct,
}

class DownloadTask {
  const DownloadTask({
    required this.url,
    required this.platform,
    this.status = TaskStatus.pending,
    this.resultUrl,
    this.error,
  });

  final String url;
  final VideoPlatform platform;
  final TaskStatus status;
  final String? resultUrl;
  final String? error;

  bool get isPending => status == TaskStatus.pending;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isFailed => status == TaskStatus.failed;

  DownloadTask copyWith({
    TaskStatus? status,
    String? resultUrl,
    String? error,
  }) {
    return DownloadTask(
      url: url,
      platform: platform,
      status: status ?? this.status,
      resultUrl: resultUrl ?? this.resultUrl,
      error: error ?? this.error,
    );
  }
}

class VideoDownloadState {
  const VideoDownloadState({
    required this.url,
    required this.tasks,
    required this.isProcessing,
    this.errorMessage,
  });

  factory VideoDownloadState.initial() => const VideoDownloadState(
        url: '',
        tasks: [],
        isProcessing: false,
      );

  final String url;
  final List<DownloadTask> tasks;
  final bool isProcessing;
  final String? errorMessage;

  VideoDownloadState copyWith({
    String? url,
    List<DownloadTask>? tasks,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return VideoDownloadState(
      url: url ?? this.url,
      tasks: tasks ?? this.tasks,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
    );
  }
}

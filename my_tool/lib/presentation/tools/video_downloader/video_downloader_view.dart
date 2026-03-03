import 'package:flutter/material.dart';

import '../../../domain/downloads/video_download_state.dart';
import 'video_downloader_view_model.dart';

class VideoDownloaderView extends StatefulWidget {
  const VideoDownloaderView({super.key});

  @override
  State<VideoDownloaderView> createState() => _VideoDownloaderViewState();
}

class _VideoDownloaderViewState extends State<VideoDownloaderView> {
  late final VideoDownloaderViewModel _viewModel;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = VideoDownloaderViewModel()
      ..addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onDownloadPressed() async {
    FocusScope.of(context).unfocus();
    await _viewModel.startDownload();
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Download video by URL',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Paste a direct video link or a link from Instagram / Snap. '
          'This tool will try to download the video into your device storage.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _viewModel.updateUrl,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: state.isInProgress ? null : _onDownloadPressed,
              icon: const Icon(Icons.download_rounded),
              label: Text(state.isInProgress ? 'Downloading...' : 'Download'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.isInProgress) ...[
          LinearProgressIndicator(
            value: state.progress > 0 && state.progress <= 1
                ? state.progress
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            'Downloading video... ${(state.progress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else if (state.isCompleted && state.filePath != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.filePath!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else if (state.isFailed && state.errorMessage != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}


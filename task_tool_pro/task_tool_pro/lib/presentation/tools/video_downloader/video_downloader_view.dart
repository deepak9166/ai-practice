import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/downloads/video_download_state.dart';
import '../../providers/app_providers.dart';

class VideoDownloaderView extends ConsumerStatefulWidget {
  const VideoDownloaderView({super.key});

  @override
  ConsumerState<VideoDownloaderView> createState() =>
      _VideoDownloaderViewState();
}

class _VideoDownloaderViewState
    extends ConsumerState<VideoDownloaderView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDownloadPressed() async {
    FocusScope.of(context).unfocus();
    await ref.read(videoDownloaderViewModelProvider).startDownload();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(videoDownloaderViewModelProvider);
    final state = viewModel.state;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Download videos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the source (Instagram / Snapchat / direct link), paste one or '
          'multiple links (one per line). The tool will first fetch the page '
          'metadata, find a direct video link and then download it.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Source:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            ChoiceChip(
              label: const Text('Instagram'),
              selected: state.platform == VideoPlatform.instagram,
              onSelected: state.isInProgress
                  ? null
                  : (_) =>
                      viewModel.updatePlatform(VideoPlatform.instagram),
            ),
            ChoiceChip(
              label: const Text('Snapchat'),
              selected: state.platform == VideoPlatform.snapchat,
              onSelected: state.isInProgress
                  ? null
                  : (_) =>
                      viewModel.updatePlatform(VideoPlatform.snapchat),
            ),
            ChoiceChip(
              label: const Text('Direct link'),
              selected: state.platform == VideoPlatform.direct,
              onSelected: state.isInProgress
                  ? null
                  : (_) =>
                      viewModel.updatePlatform(VideoPlatform.direct),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: viewModel.updateUrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Video links',
                  hintText: 'Paste one or more links, one per line',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
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
        ] else if (state.isCompleted &&
            (state.videoUrl != null || state.filePath != null)) ...[
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
                    const SizedBox(height: 4),
                    if (state.videoUrl != null) ...[
                      SelectableText(
                        state.videoUrl!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: state.videoUrl!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video URL copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy URL'),
                      ),
                    ] else ...[
                      Text(
                        state.filePath!,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ],
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


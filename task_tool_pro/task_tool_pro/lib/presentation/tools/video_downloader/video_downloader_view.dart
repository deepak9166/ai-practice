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

class _VideoDownloaderViewState extends ConsumerState<VideoDownloaderView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onUploadPressed() async {
    FocusScope.of(context).unfocus();
    final vm = ref.read(videoDownloaderViewModelProvider);
    await vm.addAndProcess();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(videoDownloaderViewModelProvider);
    final state = viewModel.state;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Download videos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Paste Instagram or Snapchat links (one per line). '
          'The platform is detected automatically from the URL.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
              onPressed: state.isProcessing && state.url.trim().isEmpty
                  ? null
                  : _onUploadPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Upload'),
            ),
          ],
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
        if (state.tasks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Queue (${state.tasks.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (state.tasks.any((t) => t.isCompleted || t.isFailed))
                TextButton.icon(
                  onPressed: viewModel.clearCompleted,
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear done'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, i) {
                final task = state.tasks[i];
                return _TaskTile(
                  task: task,
                  index: i,
                  onRetry: task.isFailed
                      ? () => viewModel.retryTask(i)
                      : null,
                  onRemove: task.isPending
                      ? () => viewModel.removeTask(i)
                      : null,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.index,
    this.onRetry,
    this.onRemove,
  });

  final DownloadTask task;
  final int index;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _buildStatusIcon(colorScheme),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.url,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _statusColor(colorScheme),
                    ),
                  ),
                  if (task.isFailed && task.error != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.error!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (task.isCompleted && task.resultUrl != null)
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Copy URL',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: task.resultUrl!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            if (onRetry != null)
              IconButton(
                icon: Icon(Icons.refresh_rounded, size: 18, color: colorScheme.primary),
                tooltip: 'Retry',
                onPressed: onRetry,
              ),
            if (onRemove != null)
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.error),
                tooltip: 'Remove from queue',
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    switch (task.status) {
      case TaskStatus.pending:
        return Icon(
          Icons.schedule_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        );
      case TaskStatus.inProgress:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TaskStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: Colors.greenAccent.shade400,
        );
      case TaskStatus.failed:
        return Icon(Icons.error_rounded, size: 20, color: colorScheme.error);
    }
  }

  String _statusLabel() {
    switch (task.status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'Processing...';
      case TaskStatus.completed:
        return 'Success';
      case TaskStatus.failed:
        return 'Failed';
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (task.status) {
      case TaskStatus.pending:
        return colorScheme.onSurfaceVariant;
      case TaskStatus.inProgress:
        return colorScheme.primary;
      case TaskStatus.completed:
        return Colors.greenAccent.shade400;
      case TaskStatus.failed:
        return colorScheme.error;
    }
  }
}

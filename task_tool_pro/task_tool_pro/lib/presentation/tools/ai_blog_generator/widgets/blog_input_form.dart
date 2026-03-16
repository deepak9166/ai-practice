import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/blog/blog_post.dart';
import '../../../providers/app_providers.dart';

/// Input form: topic, tone, word count, and the Generate button.
class BlogInputForm extends ConsumerWidget {
  const BlogInputForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(aiBlogGeneratorViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Topic ----
        TextField(
          maxLines: 2,
          minLines: 1,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateTopic(v),
          decoration: const InputDecoration(
            labelText: 'Blog topic',
            hintText:
                'e.g. "The future of renewable energy in urban environments"',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        // ---- Tone ----
        Text('Tone', style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BlogTone.values.map((tone) {
            return ChoiceChip(
              label: Text(tone.displayName),
              selected: vm.tone == tone,
              selectedColor: colorScheme.primaryContainer,
              onSelected: vm.isLoading
                  ? null
                  : (_) => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .updateTone(tone),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // ---- Target word count ----
        Text('Target word count', style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [300, 500, 800, 1200, 1500].map((count) {
            return ChoiceChip(
              label: Text('~$count words'),
              selected: vm.targetWordCount == count,
              selectedColor: colorScheme.primaryContainer,
              onSelected: vm.isLoading
                  ? null
                  : (_) => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .updateTargetWordCount(count),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // ---- Error message ----
        if (vm.hasError && vm.errorMessage != null) ...[
          _ErrorBanner(message: vm.errorMessage!),
          const SizedBox(height: 16),
        ],

        // ---- Generate button ----
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: vm.isLoading
                ? null
                : () =>
                    ref.read(aiBlogGeneratorViewModelProvider).generateBlog(),
            icon: vm.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(vm.isLoading ? 'Generating...' : 'Generate Blog'),
          ),
        ),

        // ---- No-key hint ----
        if (!vm.hasValidKey && !vm.isLoading) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'No ${vm.selectedProvider.displayName} key found. '
                  'Open Settings to add one.',
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

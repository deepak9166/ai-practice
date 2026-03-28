import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/blog/blog_article.dart';
import '../../providers/app_providers.dart';
import 'blog_writer_view_model.dart';

class BlogWriterView extends ConsumerStatefulWidget {
  const BlogWriterView({super.key});

  @override
  ConsumerState<BlogWriterView> createState() => _BlogWriterViewState();
}

class _BlogWriterViewState extends ConsumerState<BlogWriterView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogWriterViewModelProvider).loadStoredKeys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(blogWriterViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(vm: vm),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: vm.isHistoryOpen
                ? const _HistoryPanel(key: ValueKey('history'))
                : vm.isSettingsOpen
                ? const _SettingsPanel(key: ValueKey('settings'))
                : vm.hasResult
                ? const _PreviewPanel(key: ValueKey('preview'))
                : const _InputForm(key: ValueKey('input')),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.vm});
  final BlogWriterViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Mode badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: colorScheme.primaryContainer.withValues(alpha: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                vm.mode == 'gemini'
                    ? Icons.auto_awesome_rounded
                    : Icons.computer_rounded,
                size: 14,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 5),
              Text(
                vm.mode == 'gemini' ? 'Gemini' : 'Local (Ollama)',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Token status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: vm.hasPublishToken
                ? Colors.green.withValues(alpha: 0.15)
                : colorScheme.errorContainer.withValues(alpha: 0.5),
          ),
          child: Text(
            vm.hasPublishToken ? 'Publish ready' : 'No publish token',
            style: textTheme.labelSmall?.copyWith(
              color: vm.hasPublishToken
                  ? Colors.greenAccent.shade400
                  : colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          onPressed: vm.isHistoryOpen ? vm.closeHistory : vm.openHistory,
          icon: Icon(
            vm.isHistoryOpen ? Icons.close_rounded : Icons.history_rounded,
            size: 18,
          ),
          tooltip: vm.isHistoryOpen ? 'Close history' : 'History',
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: vm.isSettingsOpen ? vm.closeSettings : vm.openSettings,
          icon: Icon(
            vm.isSettingsOpen ? Icons.close_rounded : Icons.settings_rounded,
            size: 18,
          ),
          tooltip: vm.isSettingsOpen ? 'Close settings' : 'Settings',
        ),
      ],
    );
  }
}

// =============================================================================
// Settings Panel
// =============================================================================

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(blogWriterViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('API Settings', style: textTheme.titleSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Close settings',
                onPressed: vm.closeSettings,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Keys are stored securely on this device.',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Server URL
          TextFormField(
            initialValue: vm.serverUrl,
            onChanged: (v) =>
                ref.read(blogWriterViewModelProvider).updateServerUrl(v),
            decoration: const InputDecoration(
              labelText: 'Python Server URL',
              hintText: 'http://localhost:8000',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dns_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Gemini API Key
          TextFormField(
            initialValue: vm.geminiApiKey,
            obscureText: !vm.showGeminiKey,
            onChanged: (v) =>
                ref.read(blogWriterViewModelProvider).updateGeminiApiKey(v),
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'AIza...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.showGeminiKey
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                ),
                onPressed: () => ref
                    .read(blogWriterViewModelProvider)
                    .toggleGeminiKeyVisibility(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required only for Gemini mode. Get from Google AI Studio.',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Publish Auth Token
          TextFormField(
            initialValue: vm.publishToken,
            obscureText: !vm.showPublishToken,
            onChanged: (v) =>
                ref.read(blogWriterViewModelProvider).updatePublishToken(v),
            decoration: InputDecoration(
              labelText: 'Publish Auth Token (preptm)',
              hintText: 'Bearer token for publishing...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.showPublishToken
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                ),
                onPressed: () => ref
                    .read(blogWriterViewModelProvider)
                    .togglePublishTokenVisibility(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save
          Row(
            children: [
              FilledButton.icon(
                onPressed: () =>
                    ref.read(blogWriterViewModelProvider).saveKeys(),
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Settings'),
              ),
              const SizedBox(width: 12),
              if (vm.keysSaved)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.greenAccent.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.greenAccent.shade400,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Input Form
// =============================================================================

class _InputForm extends ConsumerStatefulWidget {
  const _InputForm({super.key});

  @override
  ConsumerState<_InputForm> createState() => _InputFormState();
}

class _InputFormState extends ConsumerState<_InputForm> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(blogWriterViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL
          TextField(
            controller: _urlController,
            onChanged: (v) =>
                ref.read(blogWriterViewModelProvider).updateUrl(v),
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Blog URL',
              hintText: 'https://example.com/blog-post',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link_rounded, size: 20),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _urlController.clear();
                        ref.read(blogWriterViewModelProvider).updateUrl('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Mode toggle
          Text('AI Mode', style: textTheme.labelMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'local',
                label: Text('Local (Ollama)'),
                icon: Icon(Icons.computer_rounded, size: 18),
              ),
              ButtonSegment(
                value: 'gemini',
                label: Text('Gemini'),
                icon: Icon(Icons.auto_awesome_rounded, size: 18),
              ),
            ],
            selected: {vm.mode},
            onSelectionChanged: vm.isLoading
                ? null
                : (s) =>
                      ref.read(blogWriterViewModelProvider).updateMode(s.first),
          ),
          if (vm.mode == 'gemini' && !vm.hasGeminiKey) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'No Gemini API key. Open Settings to add one.',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Article Type dropdown
          if (vm.isLoadingDropdowns)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading article types & tags...'),
                ],
              ),
            )
          else if (vm.dropdownError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vm.dropdownError!,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(blogWriterViewModelProvider)
                        .refreshDropdowns(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else ...[
            // Article Type (single select) with refresh
            Row(
              children: [
                Text('Article Type', style: textTheme.labelMedium),
                const SizedBox(width: 4),
                if (vm.isLoadingDropdowns)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  InkWell(
                    onTap: () => ref
                        .read(blogWriterViewModelProvider)
                        .refreshDropdowns(),
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue:
                  vm.articleTypes.any(
                    (e) => e.value == vm.selectedArticleTypeId,
                  )
                  ? vm.selectedArticleTypeId
                  : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_rounded, size: 20),
              ),
              isExpanded: true,
              items: vm.articleTypes
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.value,
                      child: Text(item.text),
                    ),
                  )
                  .toList(),
              onChanged: vm.isLoading
                  ? null
                  : (v) => ref
                        .read(blogWriterViewModelProvider)
                        .selectArticleType(v),
            ),
            const SizedBox(height: 16),

            // Tags (multi-select chips) with refresh
            Row(
              children: [
                Text('Tags', style: textTheme.labelMedium),
                const SizedBox(width: 4),
                if (!vm.isLoadingDropdowns)
                  InkWell(
                    onTap: () => ref
                        .read(blogWriterViewModelProvider)
                        .refreshDropdowns(),
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (vm.allTags.isEmpty)
              Text(
                'No tags available',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: vm.allTags.map((tag) {
                  final selected = vm.selectedTagIds.contains(tag.value);
                  return FilterChip(
                    label: Text(tag.text),
                    selected: selected,
                    selectedColor: colorScheme.primaryContainer,
                    onSelected: vm.isLoading
                        ? null
                        : (_) => ref
                              .read(blogWriterViewModelProvider)
                              .toggleTag(tag.value),
                  );
                }).toList(),
              ),
          ],
          const SizedBox(height: 24),

          // Error
          if (vm.hasError && vm.errorMessage != null) ...[
            _ErrorBanner(message: vm.errorMessage!),
            const SizedBox(height: 16),
          ],

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () {
                      ref
                          .read(blogWriterViewModelProvider)
                          .updateUrl(_urlController.text);
                      ref.read(blogWriterViewModelProvider).generateBlog();
                    },
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(vm.isLoading ? 'Generating...' : 'Generate Blog'),
            ),
          ),
          if (vm.isLoading) ...[
            const SizedBox(height: 12),
            Text(
              'AI processing can take 30-120 seconds...',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Preview Panel
// =============================================================================

class _PreviewPanel extends ConsumerStatefulWidget {
  const _PreviewPanel({super.key});

  @override
  ConsumerState<_PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends ConsumerState<_PreviewPanel> {
  bool _copyConfirmed = false;

  void _copyAll() {
    final data = ref.read(blogWriterViewModelProvider).articleData;
    if (data == null) return;

    final text =
        '''Title: ${data.title}
Title (Hindi): ${data.titleHindi}
Slug: ${data.slugUrl}
Keywords: ${data.keywords}
Keywords (Hindi): ${data.keywordHindi}
Summary: ${data.summary}
Summary (Hindi): ${data.summaryHindi}

--- Description ---
${data.description}

--- Description (Hindi) ---
${data.descriptionHindi}''';

    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copyConfirmed = true);
    Future<void>.delayed(const Duration(seconds: 2)).then((_) {
      if (mounted) setState(() => _copyConfirmed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(blogWriterViewModelProvider);
    final BlogArticleData? data = vm.articleData;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No article data available.', style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(blogWriterViewModelProvider).clearResult(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(blogWriterViewModelProvider).clearResult(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
            ),
            OutlinedButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () => ref.read(blogWriterViewModelProvider).generateBlog(),
              icon: vm.isLoading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(vm.isLoading ? 'Regenerating...' : 'Regenerate'),
            ),
            FilledButton.tonalIcon(
              onPressed: _copyAll,
              icon: Icon(
                _copyConfirmed ? Icons.check_rounded : Icons.copy_all_rounded,
                size: 16,
              ),
              label: Text(_copyConfirmed ? 'Copied!' : 'Copy all'),
            ),
            FilledButton.icon(
              onPressed: vm.isPublishing
                  ? null
                  : () => ref.read(blogWriterViewModelProvider).publishBlog(),
              icon: vm.isPublishing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.publish_rounded, size: 16),
              label: Text(vm.isPublishing ? 'Publishing...' : 'Publish'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Publish feedback
        if (vm.publishSuccess)
          _FeedbackBanner(
            message: 'Blog published successfully!',
            isError: false,
            onDismiss: () =>
                ref.read(blogWriterViewModelProvider).clearPublishState(),
          ),
        if (vm.publishError != null)
          _FeedbackBanner(
            message: vm.publishError!,
            isError: true,
            onDismiss: () =>
                ref.read(blogWriterViewModelProvider).clearPublishState(),
          ),
        const SizedBox(height: 4),

        // Scrollable article preview
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slug URL (read-only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          data.slugUrl,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        tooltip: 'Copy slug URL',
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: data.slugUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Slug URL copied'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Category: ${data.articleType}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (data.articleTagsDTOs.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Tags: ${data.articleTagsDTOs.join(", ")}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                _EditableSection(
                  label: 'Title',
                  initialValue: data.title,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleTitle(v),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _EditableSection(
                  label: 'Title (Hindi)',
                  initialValue: data.titleHindi,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleTitleHindi(v),
                ),
                const SizedBox(height: 16),

                // Keywords
                _EditableSection(
                  label: 'Keywords',
                  initialValue: data.keywords,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleKeywords(v),
                ),
                const SizedBox(height: 8),
                _EditableSection(
                  label: 'Keywords (Hindi)',
                  initialValue: data.keywordHindi,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleKeywordHindi(v),
                ),
                const SizedBox(height: 16),

                // Summary
                _EditableSection(
                  label: 'Summary',
                  initialValue: data.summary,
                  maxLines: 3,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleSummary(v),
                ),
                const SizedBox(height: 8),
                _EditableSection(
                  label: 'Summary (Hindi)',
                  initialValue: data.summaryHindi,
                  maxLines: 3,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleSummaryHindi(v),
                ),
                const SizedBox(height: 16),

                // Description (HTML)
                _EditableSection(
                  label: 'Description (HTML)',
                  initialValue: data.description,
                  maxLines: 10,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleDescription(v),
                ),
                const SizedBox(height: 8),
                _EditableSection(
                  label: 'Description Hindi (HTML)',
                  initialValue: data.descriptionHindi,
                  maxLines: 10,
                  onChanged: (v) => ref
                      .read(blogWriterViewModelProvider)
                      .updateArticleDescriptionHindi(v),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// History Panel
// =============================================================================

class _HistoryPanel extends ConsumerWidget {
  const _HistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(blogWriterViewModelProvider);
    final history = vm.history;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('Blog History', style: textTheme.titleSmall),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              ),
              child: Text(
                '${history.length}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              tooltip: 'Close history',
              onPressed: vm.closeHistory,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No blogs generated yet',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = history[index];
                final isPublished = entry.status == 'published';
                final date = entry.createdAt;
                final dateStr =
                    '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year}  '
                    '${date.hour.toString().padLeft(2, '0')}:'
                    '${date.minute.toString().padLeft(2, '0')}';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title.isNotEmpty ? entry.title : 'Untitled',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: isPublished
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : colorScheme.primaryContainer.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                            child: Text(
                              isPublished ? 'Published' : 'Generated',
                              style: textTheme.labelSmall?.copyWith(
                                color: isPublished
                                    ? Colors.greenAccent.shade400
                                    : colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // URL
                      Text(
                        entry.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Date + copy slug
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (entry.slugUrl.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: entry.slugUrl),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Slug URL copied'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text(
                                entry.slugUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                textStyle: textTheme.labelSmall,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Shared widgets
// =============================================================================

class _EditableSection extends StatefulWidget {
  const _EditableSection({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.style,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final int maxLines;

  @override
  State<_EditableSection> createState() => _EditableSectionState();
}

class _EditableSectionState extends State<_EditableSection> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_EditableSection old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue &&
        _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines == 1 ? null : widget.maxLines,
            minLines: 1,
            style: widget.style ?? textTheme.bodyMedium,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
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
          Icon(Icons.error_outline_rounded, size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isError ? colorScheme.error : Colors.greenAccent.shade400;
    final bgColor = isError
        ? colorScheme.errorContainer.withValues(alpha: 0.3)
        : Colors.greenAccent.shade700.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

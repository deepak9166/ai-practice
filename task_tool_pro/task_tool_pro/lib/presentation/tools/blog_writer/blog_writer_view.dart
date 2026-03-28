import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'blog_writer_view_model.dart';

/// Root screen for the Blog Writer (URL-to-Blog) tool.
///
/// Layout:
///   - Header row: token status badge + settings icon button
///   - Settings panel (shown inline when open): token field + save button
///   - URL input field
///   - Generate button
///   - Result / loading / error area
class BlogWriterView extends ConsumerStatefulWidget {
  const BlogWriterView({super.key});

  @override
  ConsumerState<BlogWriterView> createState() => _BlogWriterViewState();
}

class _BlogWriterViewState extends ConsumerState<BlogWriterView> {
  late final TextEditingController _urlController;
  late final TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _tokenController = TextEditingController();

    // Load the persisted token after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = ref.read(blogWriterViewModelProvider);
      await vm.loadStoredToken();
      // Sync the controller text with the loaded token.
      if (mounted) {
        _tokenController.text = vm.apiToken;
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(blogWriterViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header: token badge + settings button ----
        _HeaderRow(
          hasToken: vm.hasToken,
          settingsOpen: vm.isSettingsOpen,
          onSettingsTap: vm.isSettingsOpen ? vm.closeSettings : vm.openSettings,
        ),
        const SizedBox(height: 12),

        // ---- Inline settings panel ----
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: vm.isSettingsOpen
              ? _TokenSettingsPanel(tokenController: _tokenController)
              : const SizedBox.shrink(),
        ),

        // ---- URL input ----
        _UrlInputSection(urlController: _urlController),
        const SizedBox(height: 16),

        // ---- Generate button ----
        _GenerateButton(urlController: _urlController),
        const SizedBox(height: 16),

        // ---- Result area ----
        Expanded(
          child: _ResultArea(vm: vm),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header row
// ---------------------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.hasToken,
    required this.settingsOpen,
    required this.onSettingsTap,
  });

  final bool hasToken;
  final bool settingsOpen;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Token status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: hasToken
                ? colorScheme.primaryContainer.withValues(alpha: 0.8)
                : colorScheme.errorContainer.withValues(alpha: 0.7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasToken ? Icons.vpn_key_rounded : Icons.vpn_key_off_rounded,
                size: 14,
                color: hasToken
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 5),
              Text(
                hasToken ? 'Token set' : 'No token',
                style: textTheme.labelSmall?.copyWith(
                  color: hasToken
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Settings icon button
        IconButton.filledTonal(
          onPressed: onSettingsTap,
          icon: Icon(
            settingsOpen ? Icons.close_rounded : Icons.settings_rounded,
            size: 18,
          ),
          tooltip: settingsOpen ? 'Close settings' : 'Configure API token',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Token settings panel
// ---------------------------------------------------------------------------

class _TokenSettingsPanel extends ConsumerWidget {
  const _TokenSettingsPanel({required this.tokenController});

  final TextEditingController tokenController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(blogWriterViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'API Token',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'This token is sent as a Bearer header to the blog generation API. '
              'It is stored in secure storage and survives app restarts.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              obscureText: !vm.showToken,
              onChanged: (v) {
                ref.read(blogWriterViewModelProvider).updateApiToken(v);
              },
              decoration: InputDecoration(
                hintText: 'Enter your API token...',
                filled: true,
                fillColor: colorScheme.surface,
                prefixIcon: const Icon(Icons.key_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    vm.showToken
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                  onPressed: () =>
                      ref.read(blogWriterViewModelProvider).toggleTokenVisibility(),
                  tooltip: vm.showToken ? 'Hide token' : 'Show token',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    ref.read(blogWriterViewModelProvider).updateApiToken(
                          tokenController.text,
                        );
                    await ref.read(blogWriterViewModelProvider).saveToken();
                  },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save Token'),
                ),
                const SizedBox(width: 12),
                if (vm.apiToken.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      tokenController.clear();
                      await ref.read(blogWriterViewModelProvider).clearToken();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                const Spacer(),
                if (vm.tokenSaved)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// URL input section
// ---------------------------------------------------------------------------

class _UrlInputSection extends ConsumerWidget {
  const _UrlInputSection({required this.urlController});

  final TextEditingController urlController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source URL',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          onChanged: (v) =>
              ref.read(blogWriterViewModelProvider).updateUrl(v),
          decoration: InputDecoration(
            hintText: 'https://example.com/some-article',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            prefixIcon: const Icon(Icons.link_rounded, size: 18),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              onPressed: () {
                urlController.clear();
                ref.read(blogWriterViewModelProvider).updateUrl('');
              },
              tooltip: 'Clear URL',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Generate button
// ---------------------------------------------------------------------------

class _GenerateButton extends ConsumerWidget {
  const _GenerateButton({required this.urlController});

  final TextEditingController urlController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(blogWriterViewModelProvider);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: vm.isLoading
            ? null
            : () {
                // Sync controller text into VM before generating.
                ref.read(blogWriterViewModelProvider).updateUrl(urlController.text);
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
    );
  }
}

// ---------------------------------------------------------------------------
// Result area
// ---------------------------------------------------------------------------

class _ResultArea extends StatelessWidget {
  const _ResultArea({required this.vm});

  final BlogWriterViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vm.isLoading) {
      return _ResultContainer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Generating blog content...',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.hasError) {
      return _ResultContainer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.errorMessage ?? 'An unknown error occurred.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (vm.hasResult) {
      return _BlogResultContent(content: vm.blogContent!);
    }

    // ---- Empty / idle state ----
    return _ResultContainer(
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
              'Generated blog will appear here',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter a URL above and tap Generate Blog.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blog result content — scrollable, with copy and clear actions
// ---------------------------------------------------------------------------

class _BlogResultContent extends ConsumerWidget {
  const _BlogResultContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action bar
        Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 6),
            Text(
              'Blog generated',
              style: textTheme.labelMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Copy button
            IconButton.filledTonal(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blog content copied to clipboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              tooltip: 'Copy to clipboard',
            ),
            const SizedBox(width: 8),
            // Clear button
            IconButton.filledTonal(
              onPressed: () =>
                  ref.read(blogWriterViewModelProvider).clearResult(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              tooltip: 'Generate a new blog',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Scrollable content
        Expanded(
          child: _ResultContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                content,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared container decoration
// ---------------------------------------------------------------------------

class _ResultContainer extends StatelessWidget {
  const _ResultContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

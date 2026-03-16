import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/blog/blog_post.dart';
import '../../providers/app_providers.dart';
import 'widgets/api_settings_panel.dart';
import 'widgets/blog_input_form.dart';
import 'widgets/blog_preview.dart';

/// Root widget for the AI Blog Generator tool.
///
/// Handles three top-level states:
///   • Settings panel open
///   • Blog generation form (idle / loading / error)
///   • Blog preview (success)
class AiBlogGeneratorScreen extends ConsumerStatefulWidget {
  const AiBlogGeneratorScreen({super.key});

  @override
  ConsumerState<AiBlogGeneratorScreen> createState() =>
      _AiBlogGeneratorScreenState();
}

class _AiBlogGeneratorScreenState
    extends ConsumerState<AiBlogGeneratorScreen> {
  @override
  void initState() {
    super.initState();
    // Load persisted API keys after the first frame so the provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiBlogGeneratorViewModelProvider).loadStoredKeys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(aiBlogGeneratorViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Tool header ----
        _ToolHeader(
          selectedProvider: vm.selectedProvider,
          onSettingsTap: vm.isSettingsOpen
              ? vm.closeSettings
              : vm.openSettings,
          settingsOpen: vm.isSettingsOpen,
        ),
        const SizedBox(height: 16),

        // ---- Main content area ----
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colorScheme.surface.withValues(alpha: 0.9),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: vm.isSettingsOpen
                  ? const ApiSettingsPanel(key: ValueKey('settings'))
                  : vm.status == BlogGenerationStatus.success &&
                          vm.blogPost != null
                      ? BlogPreview(
                          key: ValueKey(vm.blogPost!.generatedAt),
                          post: vm.blogPost!,
                        )
                      : const BlogInputForm(key: ValueKey('input')),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tool header
// ---------------------------------------------------------------------------

class _ToolHeader extends StatelessWidget {
  const _ToolHeader({
    required this.selectedProvider,
    required this.onSettingsTap,
    required this.settingsOpen,
  });

  final ApiProvider selectedProvider;
  final VoidCallback onSettingsTap;
  final bool settingsOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Provider badge
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
                Icons.smart_toy_rounded,
                size: 14,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 5),
              Text(
                selectedProvider.displayName,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Settings button
        IconButton.filledTonal(
          onPressed: onSettingsTap,
          icon: Icon(
            settingsOpen ? Icons.close_rounded : Icons.settings_rounded,
            size: 18,
          ),
          tooltip: settingsOpen ? 'Close settings' : 'API key settings',
        ),
      ],
    );
  }
}

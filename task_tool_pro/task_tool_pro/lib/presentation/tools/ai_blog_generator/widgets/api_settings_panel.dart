import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/blog/blog_post.dart';
import '../../../providers/app_providers.dart';

/// Settings panel for entering and saving OpenAI / Gemini API keys.
class ApiSettingsPanel extends ConsumerWidget {
  const ApiSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(aiBlogGeneratorViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header row ----
        Row(
          children: [
            Icon(Icons.key_rounded, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('API Key Settings', style: textTheme.titleSmall),
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
          'Keys are stored securely on this device and never transmitted '
          'except directly to the selected AI provider.',
          style: textTheme.labelSmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // ---- Provider toggle ----
        Text('Active provider', style: textTheme.labelMedium),
        const SizedBox(height: 8),
        _ProviderToggle(),
        const SizedBox(height: 20),

        // ---- OpenAI key ----
        _ApiKeyField(
          label: 'OpenAI API Key',
          hintText: 'sk-...',
          value: vm.openAiApiKey,
          obscure: !vm.showOpenAiKey,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateOpenAiApiKey(v),
          onToggleVisibility: () =>
              ref.read(aiBlogGeneratorViewModelProvider).toggleOpenAiKeyVisibility(),
        ),
        const SizedBox(height: 12),

        // ---- Gemini key ----
        _ApiKeyField(
          label: 'Google Gemini API Key',
          hintText: 'AIza...',
          value: vm.geminiApiKey,
          obscure: !vm.showGeminiKey,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateGeminiApiKey(v),
          onToggleVisibility: () =>
              ref.read(aiBlogGeneratorViewModelProvider).toggleGeminiKeyVisibility(),
        ),
        const SizedBox(height: 12),

        // ---- Ollama settings ----
        _OllamaSettingsField(
          label: 'Ollama Model Name',
          hintText: 'llama3.1',
          value: vm.ollamaModel,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateOllamaModel(v),
        ),
        const SizedBox(height: 12),
        _OllamaSettingsField(
          label: 'Ollama Base URL',
          hintText: 'http://localhost:11434',
          value: vm.ollamaBaseUrl,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateOllamaBaseUrl(v),
        ),
        const SizedBox(height: 12),

        // ---- Publish auth token ----
        _ApiKeyField(
          label: 'Publish Auth Token (preptm)',
          hintText: 'Bearer token for publishing...',
          value: vm.authToken,
          obscure: !vm.showAuthToken,
          onChanged: (v) =>
              ref.read(aiBlogGeneratorViewModelProvider).updateAuthToken(v),
          onToggleVisibility: () =>
              ref.read(aiBlogGeneratorViewModelProvider).toggleAuthTokenVisibility(),
        ),
        const SizedBox(height: 20),

        // ---- Save button + feedback ----
        Row(
          children: [
            FilledButton.icon(
              onPressed: () =>
                  ref.read(aiBlogGeneratorViewModelProvider).saveKeys(),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Keys'),
            ),
            const SizedBox(width: 12),
            if (vm.keysSaved)
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.greenAccent.shade400, size: 18),
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

// ---------------------------------------------------------------------------
// Provider toggle
// ---------------------------------------------------------------------------

class _ProviderToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(aiBlogGeneratorViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ApiProvider.values.map((provider) {
        final isSelected = vm.selectedProvider == provider;
        return ChoiceChip(
          label: Text(provider.displayName),
          selected: isSelected,
          selectedColor: colorScheme.primaryContainer,
          onSelected: (_) => ref
              .read(aiBlogGeneratorViewModelProvider)
              .selectProvider(provider),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic API key field
// ---------------------------------------------------------------------------

class _OllamaSettingsField extends StatelessWidget {
  const _OllamaSettingsField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.computer_rounded, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic API key field
// ---------------------------------------------------------------------------

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggleVisibility,
  });

  final String label;
  final String hintText;
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            size: 20,
          ),
          tooltip: obscure ? 'Show key' : 'Hide key',
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/blog/blog_post.dart';
import '../../../providers/app_providers.dart';

/// Full blog preview with inline editing, copy, and regenerate actions.
class BlogPreview extends ConsumerStatefulWidget {
  const BlogPreview({super.key, required this.post});

  final BlogPost post;

  @override
  ConsumerState<BlogPreview> createState() => _BlogPreviewState();
}

class _BlogPreviewState extends ConsumerState<BlogPreview> {
  bool _copyConfirmed = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(
      ClipboardData(text: widget.post.toPlainText()),
    );
    setState(() => _copyConfirmed = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copyConfirmed = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(aiBlogGeneratorViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Action bar ----
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(aiBlogGeneratorViewModelProvider).clearResult(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Change topic'),
            ),
            OutlinedButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () =>
                      ref.read(aiBlogGeneratorViewModelProvider).generateBlog(),
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
              onPressed: _copyToClipboard,
              icon: Icon(
                _copyConfirmed
                    ? Icons.check_rounded
                    : Icons.copy_all_rounded,
                size: 16,
              ),
              label: Text(_copyConfirmed ? 'Copied!' : 'Copy all'),
            ),
            FilledButton.icon(
              onPressed: vm.isPublishing
                  ? null
                  : () =>
                      ref.read(aiBlogGeneratorViewModelProvider).publishBlog(),
              icon: vm.isPublishing
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.publish_rounded, size: 16),
              label: Text(vm.isPublishing ? 'Publishing...' : 'Publish'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ---- Publish feedback ----
        if (vm.publishSuccess)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade700.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.greenAccent.shade400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blog published successfully!',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .clearPublishState(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        if (vm.publishError != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.publishError!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .clearPublishState(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // ---- Blog content (scrollable) ----
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _EditableBlock(
                  label: 'Title',
                  initialValue: widget.post.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (v) => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .updateTitle(v),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate(widget.post.generatedAt),
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Introduction
                _SectionCard(
                  heading: 'Introduction',
                  content: widget.post.introduction,
                  headingEditable: false,
                  onContentChanged: (v) => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .updateIntroduction(v),
                ),
                const SizedBox(height: 12),

                // Sections
                ...widget.post.sections.asMap().entries.map((entry) {
                  final i = entry.key;
                  final section = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SectionCard(
                      heading: section.heading,
                      content: section.content,
                      headingEditable: true,
                      onHeadingChanged: (v) => ref
                          .read(aiBlogGeneratorViewModelProvider)
                          .updateSectionHeading(i, v),
                      onContentChanged: (v) => ref
                          .read(aiBlogGeneratorViewModelProvider)
                          .updateSectionContent(i, v),
                    ),
                  );
                }),

                // Conclusion
                _SectionCard(
                  heading: 'Conclusion',
                  content: widget.post.conclusion,
                  headingEditable: false,
                  onContentChanged: (v) => ref
                      .read(aiBlogGeneratorViewModelProvider)
                      .updateConclusion(v),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formattedDate(DateTime dt) {
    return 'Generated ${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Section card with inline editing
// ---------------------------------------------------------------------------

class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required this.heading,
    required this.content,
    required this.headingEditable,
    this.onHeadingChanged,
    required this.onContentChanged,
  });

  final String heading;
  final String content;
  final bool headingEditable;
  final ValueChanged<String>? onHeadingChanged;
  final ValueChanged<String> onContentChanged;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  late final TextEditingController _headingCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _headingCtrl = TextEditingController(text: widget.heading);
    _contentCtrl = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(_SectionCard old) {
    super.didUpdateWidget(old);
    // Sync controllers when the ViewModel pushes a regenerated post.
    if (old.heading != widget.heading) {
      _headingCtrl.text = widget.heading;
    }
    if (old.content != widget.content) {
      _contentCtrl.text = widget.content;
    }
  }

  @override
  void dispose() {
    _headingCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          widget.headingEditable
              ? TextField(
                  controller: _headingCtrl,
                  onChanged: widget.onHeadingChanged,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  widget.heading,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
          const SizedBox(height: 8),
          // Content
          TextField(
            controller: _contentCtrl,
            onChanged: widget.onContentChanged,
            maxLines: null,
            style: textTheme.bodyMedium,
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

// ---------------------------------------------------------------------------
// Editable block (used for the title)
// ---------------------------------------------------------------------------

class _EditableBlock extends StatefulWidget {
  const _EditableBlock({
    required this.label,
    required this.initialValue,
    required this.style,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final TextStyle? style;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableBlock> createState() => _EditableBlockState();
}

class _EditableBlockState extends State<_EditableBlock> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_EditableBlock old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) {
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
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      maxLines: null,
      style: widget.style,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

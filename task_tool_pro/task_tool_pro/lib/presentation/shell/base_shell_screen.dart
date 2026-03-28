import 'package:flutter/material.dart';

import '../../domain/tools/tool_definition.dart';
import '../tools/ai_blog_generator/ai_blog_generator_screen.dart';
import '../tools/blog_writer/blog_writer_view.dart';
import '../tools/video_downloader/video_downloader_view.dart';
import 'tool_shell_view_model.dart';

class BaseShellScreen extends StatefulWidget {
  const BaseShellScreen({super.key});

  @override
  State<BaseShellScreen> createState() => _BaseShellScreenState();
}

class _BaseShellScreenState extends State<BaseShellScreen> {
  late final ToolShellViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ToolShellViewModel()..addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onSelect(int index) {
    _viewModel.selectToolByIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final tools = _viewModel.tools;
        final selectedIndex = _viewModel.selectedIndex;

        if (isWide) {
          return _DesktopShell(
            tools: tools,
            selectedIndex: selectedIndex,
            onSelect: _onSelect,
          );
        }

        return _MobileShell(
          tools: tools,
          selectedIndex: selectedIndex,
          onSelect: _onSelect,
        );
      },
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.tools,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ToolDefinition> tools;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 260,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tool',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Multi-purpose workspace',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      itemCount: tools.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final tool = tools[index];
                        final isSelected = index == selectedIndex;

                        return _SidebarItem(
                          tool: tool,
                          isSelected: isSelected,
                          onTap: () => onSelect(index),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: colorScheme.surface.withValues(alpha: 0.9),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'More tools coming soon.',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                      colorScheme.surface.withValues(alpha: 0.9),
                    ],
                  ),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: _ToolDetailView(
                  tool: tools[selectedIndex],
                  isCompact: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.tools,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ToolDefinition> tools;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                title: const Text('My Tool'),
                subtitle: const Text('Multi-purpose workspace'),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tools.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    final isSelected = index == selectedIndex;

                    return _SidebarItem(
                      tool: tool,
                      isSelected: isSelected,
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelect(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _ToolDetailView(
            tool: tools[selectedIndex],
            isCompact: true,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        destinations: tools
            .map(
              (tool) => NavigationDestination(
                icon: Icon(tool.icon),
                label: tool.name,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.tool,
    required this.isSelected,
    required this.onTap,
    this.dense = false,
  });

  final ToolDefinition tool;
  final bool isSelected;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = isSelected
        ? colorScheme.primaryContainer.withValues(alpha: 0.9)
        : Colors.transparent;

    final foreground = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: dense ? 8 : 10,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: background,
        ),
        child: Row(
          children: [
            Icon(
              tool.icon,
              size: dense ? 18 : 20,
              color: foreground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (!dense) ...[
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: foreground.withValues(alpha: 0.85),
                              ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolDetailView extends StatelessWidget {
  const _ToolDetailView({
    required this.tool,
    required this.isCompact,
  });

  final ToolDefinition tool;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: isCompact ? 36 : 44,
                  height: isCompact ? 36 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Icon(
                    tool.icon,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ready',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colorScheme.surface.withValues(alpha: 0.9),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;

                // ---- Registered tool screens ----
                if (tool.id == 'media-tools') {
                  return const VideoDownloaderView();
                }

                if (tool.id == 'ai-blog-generator') {
                  return const AiBlogGeneratorScreen();
                }

                if (tool.id == 'blog-writer') {
                  return const BlogWriterView();
                }

                // ---- Placeholder for unimplemented tools ----
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tool workspace',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is the main area where the selected tool will appear. '
                      'As you add more features, you can plug them into this workspace.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (!isNarrow)
                      Row(
                        children: const [
                          Expanded(
                            child: _PlaceholderCard(
                              title: 'Input',
                              subtitle: 'User data, files or text go here.',
                              icon: Icons.input_rounded,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _PlaceholderCard(
                              title: 'Output',
                              subtitle:
                                  'Results from your tool are shown here.',
                              icon: Icons.outbox_rounded,
                            ),
                          ),
                        ],
                      )
                    else
                      const Column(
                        children: [
                          _PlaceholderCard(
                            title: 'Input',
                            subtitle: 'User data, files or text go here.',
                            icon: Icons.input_rounded,
                          ),
                          SizedBox(height: 12),
                          _PlaceholderCard(
                            title: 'Output',
                            subtitle:
                                'Results from your tool are shown here.',
                            icon: Icons.outbox_rounded,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

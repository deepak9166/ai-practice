import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/tools/tool_definition.dart';

/// ViewModel for the base shell screen (MVVM).
///
/// This is the single source of truth for:
/// - which tool is selected
/// - the list of available tools
class ToolShellViewModel extends ChangeNotifier {
  ToolShellViewModel() {
    _tools = _buildInitialTools();
  }

  late final List<ToolDefinition> _tools;
  int _selectedIndex = 0;

  List<ToolDefinition> get tools => _tools;

  int get selectedIndex => _selectedIndex;

  ToolDefinition get selectedTool => _tools[_selectedIndex];

  void selectToolByIndex(int index) {
    if (index < 0 || index >= _tools.length) return;
    if (index == _selectedIndex) return;

    _selectedIndex = index;
    notifyListeners();
  }

  List<ToolDefinition> _buildInitialTools() {
    return const [
      ToolDefinition(
        id: 'dashboard',
        name: 'Dashboard',
        description: 'Overview of your favourite tools.',
        icon: Icons.grid_view_rounded,
      ),
      ToolDefinition(
        id: 'text-utilities',
        name: 'Text Utilities',
        description: 'Format, transform and analyze text.',
        icon: Icons.text_fields_rounded,
      ),
      ToolDefinition(
        id: 'media-tools',
        name: 'Media Tools',
        description: 'Work with images, audio and video.',
        icon: Icons.photo_library_rounded,
      ),
      ToolDefinition(
        id: 'developer',
        name: 'Developer',
        description: 'Helpers for code and APIs.',
        icon: Icons.code_rounded,
      ),
      ToolDefinition(
        id: 'system',
        name: 'System',
        description: 'Shortcuts and automation for desktop.',
        icon: Icons.desktop_windows_rounded,
      ),
      ToolDefinition(
        id: 'ai-blog-generator',
        name: 'AI Blog Generator',
        description: 'Generate blog posts with ChatGPT or Gemini.',
        icon: Icons.edit_note_rounded,
      ),
    ];
  }
}


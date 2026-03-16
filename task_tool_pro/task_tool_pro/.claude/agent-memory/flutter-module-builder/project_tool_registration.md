---
name: Tool Registration Pattern
description: How tools are defined, registered in the shell VM, and wired to their screen widgets in base_shell_screen.dart
type: project
---

## ToolDefinition
Defined in `lib/domain/tools/tool_definition.dart`. Immutable class with: id (String), name, description, icon (IconData).

## Registration in Shell VM
Tools are added as const ToolDefinition entries inside `_buildInitialTools()` in `lib/presentation/shell/tool_shell_view_model.dart`.

## Routing to Screen
`_ToolDetailView` in `lib/presentation/shell/base_shell_screen.dart` switches on `tool.id` to render the correct screen widget. Pattern:
```dart
if (tool.id == 'media-tools') ...[
  const VideoDownloaderView(),
] else if (tool.id == 'new-tool-id') ...[
  const NewToolView(),
] else ...[
  // placeholder
]
```

## Provider Registration
Riverpod `ChangeNotifierProvider` entries go in `lib/presentation/providers/app_providers.dart`.

## ViewModel Pattern
- Extend `ChangeNotifier`
- Hold an immutable state object, expose via getter
- Use `copyWith` on state for updates
- Call `notifyListeners()` after each state change
- Views use `ConsumerStatefulWidget` + `ref.watch(provider)`

## File Layout for a Tool
```
lib/domain/<tool_name>/          # data models
lib/presentation/tools/<tool_name>/
  <tool_name>_view_model.dart
  <tool_name>_screen.dart (or _view.dart)
  widgets/                       # sub-widgets if needed
lib/presentation/providers/app_providers.dart  # add provider here
```

## Dependencies available
- flutter_riverpod, dio, path_provider already in pubspec.yaml
- flutter_secure_storage must be added to pubspec.yaml when needed

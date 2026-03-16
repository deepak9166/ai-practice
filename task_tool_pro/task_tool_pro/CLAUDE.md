# Task Tool Pro

## Project Overview
Flutter multi-platform tool workspace/shell app with pluggable tools.
Supports Android, iOS, macOS, Linux, Windows, and Web.

## Tech Stack
- **Flutter** 3.10.1+, Dart SDK
- **State Management:** Riverpod + ChangeNotifier (MVVM pattern)
- **HTTP:** Dio
- **Theme:** Material 3, dark mode, seed color: `Colors.indigo`

## Architecture
```
lib/
├── main.dart                              # Entry point (ProviderScope)
├── app/my_tool_app.dart                   # MaterialApp config
├── domain/                                # Models & entities
│   ├── tools/tool_definition.dart         # ToolDefinition model
│   └── downloads/video_download_state.dart
├── presentation/
│   ├── shell/                             # Main shell (adaptive desktop/mobile)
│   │   ├── base_shell_screen.dart         # Responsive layout (≥800dp = desktop)
│   │   └── tool_shell_view_model.dart     # Shell navigation VM
│   ├── tools/                             # Individual tool screens
│   │   └── video_downloader/
│   └── providers/app_providers.dart       # Riverpod providers
```

### Patterns
- **MVVM:** ViewModels extend `ChangeNotifier`, wrapped in Riverpod providers
- **Views:** `ConsumerStatefulWidget` for Riverpod-connected screens
- **Responsive:** `LayoutBuilder` — sidebar on desktop, drawer+bottom nav on mobile
- **Tool Plugin System:** Tools registered as `ToolDefinition`, rendered by `_ToolDetailView`

## Current Tools
1. Dashboard
2. Text Utilities
3. Media Tools (Video Downloader — Instagram, Snapchat, direct links)
4. Developer
5. System

## Backend
- Video download API at `localhost:8000` (Instagram/Snapchat endpoints)

## Build Commands
```bash
flutter run
flutter build <platform>
flutter analyze
```

## Dependencies
| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| dio | HTTP/downloads |
| path_provider | File system paths |

## Conventions
- No routing library — simple home-based navigation
- No database — stateless tool operations
- Dark theme by default
- Responsive breakpoint: 800dp width

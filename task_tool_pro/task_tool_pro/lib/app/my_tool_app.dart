import 'package:flutter/material.dart';

import '../presentation/shell/base_shell_screen.dart';

class MyToolApp extends StatelessWidget {
  const MyToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'My Tool',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surfaceVariant,
          foregroundColor: colorScheme.onSurfaceVariant,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const BaseShellScreen(),
    );
  }
}


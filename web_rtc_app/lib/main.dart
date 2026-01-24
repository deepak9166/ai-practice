import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/ai_chat/ai_chat_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/connection_status_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/file_transfer_screen.dart';

Future<void> main() async {


    WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Gemma
  // Use WebStorageMode.streaming for large models (E4B 4GB+, 7B, 27B)
  // Use WebStorageMode.cacheApi for smaller models (default, faster)
  await FlutterGemma.initialize(
    webStorageMode: WebStorageMode.cacheApi,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebRTC Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/qr-scanner': (context) => const QRScannerScreen(),
        '/connection-status': (context) => const ConnectionStatusScreen(),
        '/chat': (context) => const ChatScreen(),
        '/file-transfer': (context) => const FileTransferScreen(),
        '/ai-chat-screen': (context) => const AIChatHomeScreen(),
      },
    );
  }
}

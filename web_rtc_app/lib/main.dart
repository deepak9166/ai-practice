import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/connection_status_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/file_transfer_screen.dart';

void main() {
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
      },
    );
  }
}

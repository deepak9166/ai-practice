import 'dart:core';

import 'package:flutter/material.dart';
// import 'package:flutter_background/flutter_background.dart';

import 'src/web_rtc_connection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SplashPage());
}

// Future<bool> startForegroundService() async {
//   final androidConfig = FlutterBackgroundAndroidConfig(
//     notificationTitle: 'Title of the notification',
//     notificationText: 'Text of the notification',
//     notificationImportance: AndroidNotificationImportance.normal,
//     notificationIcon: AndroidResource(
//         name: 'background_icon',
//         defType: 'drawable'), // Default is ic_launcher from folder mipmap
//   );
//   await FlutterBackground.initialize(androidConfig: androidConfig);
//   return FlutterBackground.enableBackgroundExecution();
// }

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebRTCManualSDPPage(),
    );
  }
}




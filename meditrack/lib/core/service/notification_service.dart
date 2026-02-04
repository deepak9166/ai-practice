import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // await requestExactAlarmPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestFullScreenIntentPermission();

    // IOS
    // await _plugin
    //     .resolvePlatformSpecificImplementation<
    //       IOSFlutterLocalNotificationsPlugin
    //     >()
    //     ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTap(NotificationResponse response) {
    final actionId = response.actionId;
    final notificationId = response.id; // 👈 VERY IMPORTANT
    final payload = response.payload;

    if (notificationId == null) return;

    switch (actionId) {
      case 'SNOOZE_5':
        _snooze(notificationId, const Duration(minutes: 5), payload);
        break;

      case 'SNOOZE_10':
        _snooze(notificationId, const Duration(minutes: 10), payload);
        break;

      default:
        // Normal tap → open app
        break;
    }
  }

  Future<void> _snooze(
    int notificationId,
    Duration delay,
    String? payload,
  ) async {
    final newTime = DateTime.now().add(delay);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Medicine Reminder 💊',
      body: 'Reminder postponed',
      scheduledDate: tz.TZDateTime.from(newTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      payload: payload,
    );
  }

  final androidNotificationDetail = const NotificationDetails(
    android: AndroidNotificationDetails(
      'medicine_channel',
      'Medicine Reminders',
      channelDescription: 'Medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          'SNOOZE_5',
          '+5 min',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'SNOOZE_10',
          '+10 min',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'DISMISS',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    ),
  );

  Future<void> scheduleMedicineReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: androidNotificationDetail,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  showNotificationInApp() {
    _plugin.show(
      id: 141752,
      title: "Hello Bro  testtt ",
      body: "Notification test",
      notificationDetails: androidNotificationDetail,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  // Other functions
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }
}

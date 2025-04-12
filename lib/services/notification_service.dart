import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_channel_id',
      'Medication Reminders',
      description: 'Channel for medication reminders',
      importance: Importance.max,
      playSound: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      final androidDetails = const AndroidNotificationDetails(
        'med_channel_id',
        'Medication Reminders',
        channelDescription: 'Channel for medication reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );

      // await _flutterLocalNotificationsPlugin.show(
      //   0,
      //   'Test Now',
      //   'App is in foreground',
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       'med_channel_id',
      //       'Medication Reminders',
      //       channelDescription: 'Reminder testing in foreground',
      //       importance: Importance.max,
      //       priority: Priority.high,
      //     ),
      //   ),
      // );


      print('Notification scheduled successfully for $scheduledDateTime');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }
}
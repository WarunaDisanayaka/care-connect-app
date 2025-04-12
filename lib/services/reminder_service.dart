import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class ReminderService {
  static Future<void> scheduleInAppReminder({
    required String medicationName,
    required DateTime scheduledDateTime,
  }) async {
    print("Reminder set for $medicationName at $scheduledDateTime");

    // Convert to TZDateTime
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'med_reminder_channel',
      'Medication Reminders',
      channelDescription: 'Reminders for taking medicine',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   scheduledDateTime.millisecondsSinceEpoch ~/ 1000, // Unique ID
    //   '💊 Time for your medicine',
    //   'Take $medicationName now!',
    //   tzDateTime,
    //   platformChannelSpecifics,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   matchDateTimeComponents: DateTimeComponents.time, // Optional: For repeating daily
    // );
  }
}

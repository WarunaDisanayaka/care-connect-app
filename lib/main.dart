import 'package:careconnect_app/screens/family_member_home_screen.dart';
import 'package:careconnect_app/services/notification_service.dart';
import 'package:careconnect_app/services/permissions_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:careconnect_app/screens/login_screen.dart';
import 'package:careconnect_app/services/medication_service.dart';
import 'package:careconnect_app/services/settings_provider.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Colombo')); // Or your time zone
  await initializeNotifications(); // Initialize the notifications

  await Firebase.initializeApp();
  await NotificationService.init();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await FirebaseMessaging.instance.subscribeToTopic("sample");

  runApp(const CareConnectApp());
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Your app icon

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MedicationService()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Care Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FirebaseAuth.instance.currentUser == null
            ? LoginScreen()
            : FamilyMemberHomeScreen(userData: {
          'name': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
          'email': FirebaseAuth.instance.currentUser?.email ?? 'user@example.com',
        }),
      ),

    );
  }
}

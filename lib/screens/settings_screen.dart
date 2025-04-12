import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ✅ Load Settings from SharedPreferences & Sync with Firebase
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool savedStatus = prefs.getBool('notifications') ?? true;

    setState(() => _notificationsEnabled = savedStatus);

    // ✅ Ensure Firebase Subscription is in sync
    _checkFirebaseSubscription(savedStatus);
  }

  // ✅ Sync Firebase Subscription with SharedPreferences
  Future<void> _checkFirebaseSubscription(bool status) async {
    try {
      if (status) {
        await _firebaseMessaging.subscribeToTopic("all_users");
      } else {
        await _firebaseMessaging.unsubscribeFromTopic("all_users");
      }
    } catch (e) {
      print("Error syncing Firebase subscription: $e");
    }
  }

  // ✅ Toggle Notifications with Firebase & SharedPreferences
  void _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);

    try {
      if (value) {
        await _firebaseMessaging.subscribeToTopic("all_users");
      } else {
        await _firebaseMessaging.unsubscribeFromTopic("all_users");
      }
    } catch (e) {
      print("Error toggling notifications: $e");
    }

    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.pink,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔔 Enable Notifications
            _buildSwitchTile(
              "Enable Notifications",
              _notificationsEnabled,
              Icons.notifications,
              _toggleNotifications,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Switch Tile
  Widget _buildSwitchTile(String title, bool value, IconData icon, Function(bool) onChanged) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.pink,
        ),
      ),
    );
  }
}

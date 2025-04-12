import 'dart:convert';
import 'package:careconnect_app/screens/family_member_home_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FamilyLoginScreen extends StatefulWidget {
  @override
  _FamilyLoginScreenState createState() => _FamilyLoginScreenState();
}

class _FamilyLoginScreenState extends State<FamilyLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _loginFamilyMember() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String hashedPassword = _hashPassword(password);

    try {
      // Search family_members subcollections for matching credentials
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('family_members')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: hashedPassword)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = snapshot.docs.first;

        // Get FCM token
        String? token = await FirebaseMessaging.instance.getToken();

        // Save/update FCM token
        await userDoc.reference.update({"fcm_token": token});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyMemberHomeScreen(userData: {},),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials or user not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Family Member Login"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loginFamilyMember,
            child: Text("Login"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          ),
        ]),
      ),
    );
  }
}

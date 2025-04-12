import 'package:careconnect_app/screens/family_member_login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:careconnect_app/screens/medication_screen.dart';

import 'family_member_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hash the password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Show progress indicator while processing
  void _showLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  // Sign Up
  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String hashedPassword = _hashPassword(password);

    _showLoading(true);

    try {
      var userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        _showLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username already exists!')),
        );
        return;
      }

      await _firestore.collection('users').doc(username).set({
        'username': username,
        'password': hashedPassword,
      });

      _showLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-Up Successful! Please login.')),
      );
    } catch (e) {
      _showLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Log In
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String hashedPassword = _hashPassword(password);

    _showLoading(true);

    try {
      var userDoc = await _firestore.collection('users').doc(username).get();
      if (!userDoc.exists || userDoc['password'] != hashedPassword) {
        _showLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password!')),
        );
        return;
      }

      _showLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationScreen(username: username),
        ),
      );
    } catch (e) {
      _showLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade100, Colors.pink.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Foreground Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.medical_services,
                          size: 50,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(height: 20),

                      // App Title
                      Text(
                        'Care Connect',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: Icon(Icons.person, color: Colors.pink),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your username' : null,
                      ),
                      SizedBox(height: 20),

                      // Password Field with Toggle
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.pink),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your password' : null,
                      ),
                      SizedBox(height: 30),

                      // Login Button
                      MouseRegion(
                        onEnter: (_) => setState(() {}),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Sign Up Button
                      MouseRegion(
                        onEnter: (_) => setState(() {}),
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.pink),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to the Family Member Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyLoginScreen(), // Link to your Family Member Screen
                        ),
                      );
                    },
                    child: Text(
                      'Family Member Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Progress Indicator
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _imageFile;
  String? _imageUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // **Load user profile data from Firestore**
  void _loadUserProfile() async {
    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(widget.username).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
        _phoneController.text = userDoc['phone'] ?? '';
        _imageUrl = userDoc['profileImage'] ?? null;
      });
    }
  }

  // **Pick an image from gallery or camera**
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload image to Firebase Storage
      await _uploadImage();
    }
  }

  // **Upload image to Firebase Storage and get URL**
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    String fileName = '${widget.username}_profile.jpg';
    Reference storageRef = _storage.ref().child('profile_pictures/$fileName');

    try {
      await storageRef.putFile(_imageFile!);
      String downloadURL = await storageRef.getDownloadURL();

      setState(() {
        _imageUrl = downloadURL;
      });

      // Save URL to Firestore
      await _firestore.collection('users').doc(widget.username).update({
        'profileImage': downloadURL,
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // **Update user profile in Firestore**
  void _updateProfile() async {
    await _firestore.collection('users').doc(widget.username).update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile Updated Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text("View Profile"),
        backgroundColor: Colors.pink,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // **Profile Image Upload**
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.pink.shade100,
                backgroundImage: _imageUrl != null
                    ? NetworkImage(_imageUrl!)
                    : AssetImage('assets/images/female_avatar.jpg') as ImageProvider,
                child: _imageUrl == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 15),

            // **Profile Input Fields**
            _buildTextField(_nameController, "Full Name", Icons.person),
            _buildTextField(_emailController, "Email", Icons.email),
            _buildTextField(_phoneController, "Phone Number", Icons.phone),
            SizedBox(height: 15),

            // **Edit Profile Button**
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: Text("Edit Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // **Reusable Text Field**
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMemberScreen extends StatefulWidget {
  final String username;

  FamilyMemberScreen({required this.username});

  @override
  _FamilyMemberScreenState createState() => _FamilyMemberScreenState();
}

class _FamilyMemberScreenState extends State<FamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _hashPassword(String _passwordController) {
    final bytes = utf8.encode(_passwordController);
    return sha256.convert(bytes).toString();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _editingDocId;

  void _addOrUpdateFamilyMember() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> memberData = {
        "name": _nameController.text.trim(),
        "relation": _relationController.text.trim(),
        "phone": _phoneController.text.trim(),
        "age": _ageController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _hashPassword(_passwordController.text.trim()),

      };

      if (_editingDocId == null) {
        // **Add new family member**
        await _firestore
            .collection('users')
            .doc(widget.username)
            .collection('family_members')
            .add(memberData);
      } else {
        // **Update existing family member**
        await _firestore
            .collection('users')
            .doc(widget.username)
            .collection('family_members')
            .doc(_editingDocId)
            .update(memberData);
        _editingDocId = null; // Reset editing state
      }

      _clearForm();
    }
  }

  void _removeFamilyMember(String docId) async {
    await _firestore
        .collection('users')
        .doc(widget.username)
        .collection('family_members')
        .doc(docId)
        .delete();
  }

  void _editFamilyMember(String docId, Map<String, dynamic> data) {
    setState(() {
      _editingDocId = docId;
      _nameController.text = data["name"];
      _relationController.text = data["relation"];
      _phoneController.text = data["phone"];
      _ageController.text = data["age"];
      _emailController.text = data["email"];
    });
  }

  void _clearForm() {
    _nameController.clear();
    _relationController.clear();
    _phoneController.clear();
    _ageController.clear();
    _emailController.clear();
    _editingDocId = null;
    _passwordController.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text("Family Members"),
        backgroundColor: Colors.pink,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, "Full Name", Icons.person, (value) {
                      if (value!.isEmpty) return "Name is required";
                      return null;
                    }),
                    _buildTextField(_relationController, "Relationship", Icons.family_restroom, (value) {
                      if (value!.isEmpty) return "Relationship is required";
                      return null;
                    }),
                    _buildTextField(_phoneController, "Phone Number", Icons.phone, (value) {
                      if (value!.isEmpty) return "Phone number is required";
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Enter a valid 10-digit number";
                      return null;
                    }),
                    _buildTextField(_ageController, "Age", Icons.cake, (value) {
                      if (value!.isEmpty) return "Age is required";
                      if (int.tryParse(value) == null) return "Enter a valid age";
                      return null;
                    }),
                    _buildTextField(_emailController, "Email Address", Icons.email, (value) {
                      if (value!.isEmpty) return "Email is required";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
                      return null;
                    }),
                    _buildTextField(
                      _passwordController,
                      "Password",
                      Icons.lock,
                          (value) {
                        if (value == null || value.isEmpty) return "Password is required";
                        if (value.length < 6) return "Password must be at least 6 characters";
                        return null;
                      },
                    ),

                  ],
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _addOrUpdateFamilyMember,
                icon: Icon(Icons.person_add_alt_1, color: Colors.white),
                label: Text(_editingDocId == null ? "Add Family Member" : "Update Family Member"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  elevation: 8,
                  shadowColor: Colors.pink.shade200,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(widget.username)
                      .collection('family_members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final members = snapshot.data!.docs;

                    if (members.isEmpty) {
                      return Center(
                        child: Text(
                          "No family members added yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        var memberData = members[index].data() as Map<String, dynamic>;
                        return _buildMemberCard(members[index].id, memberData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink.shade200),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(String docId, Map<String, dynamic> memberData) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.pink.shade200,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: Icon(Icons.person, color: Colors.pink),
        ),
        title: Text(
          memberData["name"]!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Relation: ${memberData["relation"]}"),
            Text("Phone: ${memberData["phone"]}"),
            Text("Age: ${memberData["age"]}"),
            Text("Email: ${memberData["email"]}"),
          ],
        ),
        trailing: Wrap(
          children: [
            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _editFamilyMember(docId, memberData)),
            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _removeFamilyMember(docId)),
          ],
        ),
      ),
    );
  }
}

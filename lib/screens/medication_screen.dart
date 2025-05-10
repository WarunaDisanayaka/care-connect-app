import 'package:careconnect_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../models/medication.dart';
import '../widgets/medication_card.dart';
import 'addmedicine_screen.dart';
import 'family_member_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MedicationScreen extends StatefulWidget {
  final String username;

  MedicationScreen({required this.username});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  String _sortOption = 'name'; // Default sorting option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(
          'Medication Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pink,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade50,
                Colors.pink.shade100,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // **Profile Section**
              Container(
                margin: EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 3),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.pink.shade100,
                      child: Icon(Icons.person, size: 50, color: Colors.pink),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.username,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                    Text(
                      "user@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // **Menu Items**
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      icon: Icons.people,
                      title: "Family Member",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FamilyMemberScreen(username: widget.username)),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: "View Profile",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen(username: widget.username)),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: "Settings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsScreen()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                        // Handle logout logic here
                        print("User logged out");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // **Header with Add Button**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/medicine.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMedicineScreen(username: widget.username)),
                    );

                    if (result == true) {
                      Provider.of<MedicationService>(context, listen: false).notifyListeners();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    shadowColor: Colors.pink.shade200,
                    elevation: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: Text(
                      '➕ Add a New Medicine',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Stay on top of your health! Schedule your medications effortlessly.",
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // **Medication List**
          Expanded(
            child: Consumer<MedicationService>(
              builder: (context, medicationService, child) {
                return StreamBuilder<List<Medication>>(
                  stream: medicationService.getMedications(widget.username),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<Medication> medications = snapshot.data!;

                    // **Sort medications based on selection**
                    if (_sortOption == 'sort_by_name') {
                      medications.sort((a, b) => a.name.compareTo(b.name));
                    } else if (_sortOption == 'sort_by_time') {
                      medications.sort((a, b) => a.time.compareTo(b.time));
                    }

                    if (medications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No Medications Found',
                            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        final medication = medications[index];

                        return MedicationCard(
                          medication: medication,
                          onDelete: () async {
                            await medicationService.deleteMedication(medication.id);
                          },
                          onUpdate: (updatedMedication) async {
                            await medicationService.updateMedication(
                              updatedMedication.id,
                              {
                                'medicationName': updatedMedication.name,
                                'dose': updatedMedication.dose,
                                'time': updatedMedication.time,
                                'date': Timestamp.fromDate(updatedMedication.date),
                              },
                            );
                            print("WIDGET USERNAME"+ widget.username);

                            setState(() {}); // Explicitly trigger a rebuild
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // **Custom Function to Build Drawer Items**
  Widget _buildDrawerItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.pink.shade100,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink, size: 28),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

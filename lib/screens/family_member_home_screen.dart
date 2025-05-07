import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../widgets/medication_card.dart';
import 'family_member_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class FamilyMemberHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  FamilyMemberHomeScreen({required this.userData});

  @override
  _FamilyMemberHomeScreenState createState() => _FamilyMemberHomeScreenState();
}

class _FamilyMemberHomeScreenState extends State<FamilyMemberHomeScreen> {
  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome"), backgroundColor: Colors.pink),
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
              // Profile section
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
                      widget.userData['name'] ?? "User",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                    Text(
                      widget.userData['email'] ?? "user@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  children: [

                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<MedicationService>(
        builder: (context, medicationService, child) {
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return Center(child: Text('No patients found'));
              }

              final users = snapshot.data!.docs;
              List<Future<Map<String, dynamic>?>> futureChecks = users.map((doc) async {
                final familyMembersSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('family_members')
                    .where('email', isEqualTo: widget.userData['email'])
                    .get();

                if (familyMembersSnapshot.docs.isNotEmpty) {
                  return {
                    'name': doc['name'],
                    'email': doc['email'],
                    'age': doc['age'],
                    'condition': doc['condition'],
                  };
                } else {
                  return null;
                }
              }).toList();

              return FutureBuilder<List<Map<String, dynamic>?>>(
                future: Future.wait(futureChecks),
                builder: (context, patientsSnapshot) {
                  if (patientsSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final validPatients = (patientsSnapshot.data ?? []).whereType<Map<String, dynamic>>().toList();

                  return StreamBuilder<List<Medication>>(
                    stream: medicationService.getMedications(widget.userData['patientEmail']),
                    builder: (context, medSnapshot) {
                      if (!medSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      List<Medication> medications = medSnapshot.data!;
                      String _sortOption = 'sort_by_name';

                      if (_sortOption == 'sort_by_name') {
                        medications.sort((a, b) => a.name.compareTo(b.name));
                      } else if (_sortOption == 'sort_by_time') {
                        medications.sort((a, b) => a.time.compareTo(b.time));
                      }

                      return ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          if (validPatients.isEmpty)
                            Center(child: Text('Your Patient Medication Schedule.'))
                          else
                            ...validPatients.map((patient) => Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.person, color: Colors.pink),
                                title: Text(patient['name']),
                                subtitle: Text("Email: ${patient['email']}\nCondition: ${patient['condition']}"),
                              ),
                            )),
                          SizedBox(height: 16),
                          if (medications.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'No Medications Found',
                                  style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          else
                            ...medications.map((medication) => MedicationCard(
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
                                setState(() {});
                              },
                            )),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),





    );
  }
}

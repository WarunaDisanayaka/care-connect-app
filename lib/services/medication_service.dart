import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class MedicationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // **Fetch Medications**
  Stream<List<Medication>> getMedications(String username) {
    return _firestore
        .collection('medications')
        .where('username', isEqualTo: username)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Medication.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  // **Add Medication**
  Future<void> addMedication(Map<String, dynamic> newMedication) async {
    try {
      await _firestore.collection('medications').add(newMedication);
      notifyListeners(); // **🔹 Refresh UI after adding**
    } catch (e) {
      print("Error adding medication: $e");
    }
  }

  // **Update Medication**
  Future<void> updateMedication(String documentId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('medications').doc(documentId).update(updatedData);
      notifyListeners(); // **🔹 Refresh UI after updating**
    } catch (e) {
      print("Error updating medication: $e");
    }
  }

  // **Delete Medication**
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _firestore.collection('medications').doc(medicationId).delete();
      notifyListeners(); // **🔹 Refresh UI after deleting**
    } catch (e) {
      print("Error deleting medication: $e");
    }
  }
}

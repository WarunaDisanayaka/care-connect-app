import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dose;
  final String time;
  final DateTime date;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.date,
  });

  // FIX: Ensure proper DateTime conversion
  factory Medication.fromFirestore(String id, Map<String, dynamic> data) {
    return Medication(
      id: id,
      name: data['medicationName'] ?? 'No Name',
      dose: data['dose'] ?? 'No Dose',
      time: data['time'] ?? 'No Time',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date'].toString()),
    );
  }

  // FIX: Ensure DateTime is converted to Firestore Timestamp before saving
  Map<String, dynamic> toMap() {
    return {
      'medicationName': name,
      'dose': dose,
      'time': time,
      'date': Timestamp.fromDate(date), // Ensure it's saved as Timestamp
    };
  }
}

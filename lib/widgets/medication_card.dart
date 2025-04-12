import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/voice_service.dart';
import '../screens/addmedicine_screen.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onDelete;
  final Function(Medication) onUpdate; // ✅ Added onUpdate callback

  MedicationCard({required this.medication, required this.onDelete, required this.onUpdate});

  final VoiceService _voiceService = VoiceService();

  void _navigateToEditMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(
          username: medication.id,
          isEditing: true,
          documentId: medication.id, // ✅ Ensure this is correct
          initialData: {
            'medicationName': medication.name,
            'dose': medication.dose,
            'time': medication.time,
            'date': medication.date, // ✅ Ensure correct format
          },
        ),
      ),
    ).then((updatedData) {
      if (updatedData != null && updatedData is Medication) {
        onUpdate(updatedData); // ✅ Updates UI with the new medication
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.pink.shade100,
            child: Icon(Icons.medication, color: Colors.pink),
          ),
          title: Text(
            medication.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.black87),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text('⏰ Time: ${medication.time}'),
              SizedBox(height: 6),
              Text('💊 Dose: ${medication.dose}'),
              SizedBox(height: 6),
              Text(
                '📅 Date: ${medication.date.day}-${medication.date.month}-${medication.date.year}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _navigateToEditMedicine(context),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          onTap: () => _voiceService.speak(
              "${medication.name}, Dose: ${medication.dose}, Time: ${medication.time}"),
        ),
      ),
    );
  }
}

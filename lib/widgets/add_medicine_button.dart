import 'package:flutter/material.dart';
import '../screens/addmedicine_screen.dart';
import '../services/voice_service.dart';

class AddMedicineButton extends StatelessWidget {
  final String username;

  AddMedicineButton({required this.username});

  final VoiceService _voiceService = VoiceService();

  void _navigateToAddMedicine(BuildContext context) {
    _voiceService.speak("Navigating to add a new medicine.");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicineScreen(username: username, isEditing: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToAddMedicine(context),
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
    );
  }
}

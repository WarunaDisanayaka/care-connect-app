import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';
import '../services/permissions_helper.dart';
import '../services/reminder_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final String username;
  final bool isEditing;
  final String? documentId;
  final Map<String, dynamic>? initialData;

  AddMedicineScreen({
    required this.username,
    this.isEditing = false,
    this.documentId,
    this.initialData,
  });

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _medicationNameController = TextEditingController();
  final _doseController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialData != null) {
      _medicationNameController.text = widget.initialData!['medicationName'] ?? '';
      _doseController.text = widget.initialData!['dose'] ?? '';
      _timeController.text = widget.initialData!['time'] ?? '';

      if (widget.initialData!.containsKey('date')) {
        _selectedDate = (widget.initialData!['date'] is Timestamp)
            ? (widget.initialData!['date'] as Timestamp).toDate()
            : DateTime.tryParse(widget.initialData!['date'].toString());
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveMedicine() async {
    if (_medicationNameController.text.isEmpty ||
        _doseController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Please fill in all fields!')),
      );
      return;
    }

    final medicationService = Provider.of<MedicationService>(context, listen: false);

    final updatedData = {
      'username': widget.username,
      'medicationName': _medicationNameController.text.trim(),
      'dose': _doseController.text.trim(),
      'time': _timeController.text.trim(),
      'date': Timestamp.fromDate(_selectedDate!),
    };

    try {
      if (widget.isEditing) {
        await medicationService.updateMedication(widget.documentId!, updatedData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Medication Updated Successfully!')));
      } else {
        await medicationService.addMedication(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Medication Added Successfully!')));
      }

      medicationService.notifyListeners();

      Navigator.pop(context, updatedData); // Pass the updated data back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }

// Extract selected time from _timeController
    final timeParts = _timeController.text.split(' ');
    final timeString = timeParts[0]; // e.g. "12:30"
    final amPm = timeParts.length > 1 ? timeParts[1] : ''; // AM or PM

    final timePartsSplit = timeString.split(':');
    int hour = int.parse(timePartsSplit[0]);
    int minute = int.parse(timePartsSplit[1]);

// Convert to 24-hour format
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

// Combine selected date with parsed time
    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      minute,
    );


// Schedule the in-app reminder
    ReminderService.scheduleInAppReminder(
      medicationName: _medicationNameController.text.trim(),
      scheduledDateTime: scheduledDateTime,
    );


    testNotification(scheduledDateTime, _medicationNameController.text.trim());

  }



  // In your AddMedicineScreen or other widgets
  void testNotification(DateTime scheduledTime,medicationName) async {
    try {
      print("Test Notification button pressed");
      final DateTime scheduledDateTime = DateTime.now().add(Duration(seconds: 10));
      print("Scheduled Time: $scheduledDateTime");

      await NotificationService.scheduleNotification(
        title: "Take Your " + medicationName,
        body: medicationName,
        scheduledDateTime: scheduledTime,
      );

      print("Scheduled test notification successfully");
    } catch (e) {
      print("Error during test notification: $e");
    }
  }



  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a Medicine',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade400,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.pink.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(2, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField('Medication Name', Icons.medication, _medicationNameController),
                buildTextField('Dose', Icons.local_pharmacy, _doseController),
                buildTimePicker(),
                buildDatePicker(context),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: Colors.pink.shade300,
                    elevation: 10,
                  ),
                  child: Text(
                    widget.isEditing ? 'Update Medicine' : 'Save Medicine',
                    style: TextStyle(
                      fontSize: 20, // Increased font size for better readability
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: testNotification,  // Call testNotification when the button is pressed
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue.shade600,
                //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //     shadowColor: Colors.blue.shade300,
                //     elevation: 10,
                //   ),
                //   child: Text(
                //     'Test Notification',
                //     style: TextStyle(
                //       fontSize: 20, // Increased font size for better readability
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //       letterSpacing: 1.2,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18, // Increased font size for readability
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            style: TextStyle(fontSize: 18), // Larger text input
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.pink.shade300, size: 28), // Light pink icons
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Time",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  _timeController.text = pickedTime.format(context);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeController.text.isEmpty ? 'Select a time' : _timeController.text,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Icon(Icons.access_time, color: Colors.pink.shade300, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null ? 'Select a date' : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Icon(Icons.calendar_today, color: Colors.pink.shade300, size: 28), // Light pink icon
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

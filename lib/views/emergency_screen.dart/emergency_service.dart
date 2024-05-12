import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/services/firebase_firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyServicePage extends StatefulWidget {
  @override
  _EmergencyServicePageState createState() => _EmergencyServicePageState();
}

class _EmergencyServicePageState extends State<EmergencyServicePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  late DateTime date = DateTime.now(); // Initialize date variable

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    date = DateTime.now();

    super.dispose();
  }

  void _makePhoneCall() async {
    // Placeholder emergency number - replace with actual emergency number
    const emergencyNumber = '123';
    final Uri emergencyUri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(emergencyUri)) {
      await launchUrl(emergencyUri);
    } else {
      throw 'Could not launch $emergencyNumber';
    }
  }

  void _preBookAmbulance() {
    // Implement pre-booking logic
    // This could involve sending the data to a backend or otherwise processing the request
    print('Pre-booking ambulance for:');
    print('Name: ${_nameController.text}');
    print('Location: ${_locationController.text}');
    print('Time: ${_timeController.text}');

    FirebaseFirestoreService().storeAmbulanceBooking(
        context,
        _nameController.text.toString(),
        _locationController.text.toString(),
        _timeController.text.toString(),
        date);

    _nameController.text = "";
    _locationController.text = "";
    _timeController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Emergency Service", showicon: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _makePhoneCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Background color
                foregroundColor: Colors.white, // Text Color (Foreground color)
              ),
              child: const Text('Call Ambulance'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${date.year}-${date.month}-${date.day}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Desired Time for Ambulance',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                // Prevent Keyboard from appearing
                FocusScope.of(context).requestFocus(new FocusNode());
                // Show Date Picker Here
                final TimeOfDay? pickedTime = await showTimePicker(
                  initialTime: TimeOfDay.now(),
                  context: context,
                );
                if (pickedTime != null) {
                  _timeController.text = pickedTime.format(context);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _preBookAmbulance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Background color
                foregroundColor: Colors.black, // Text Color (Foreground color)
              ),
              child: const Text('Pre-Book Ambulance'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }
}

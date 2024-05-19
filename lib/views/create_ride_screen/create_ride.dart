import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/services/firebase_firestore_services.dart';
import 'package:demo_project1/views/location/location_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../location/provider/location_provider.dart';

class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  late String startLocation;
  late String endLocation;
  final _formKey = GlobalKey<FormState>();
  String tripType = 'One Time'; // Variable to keep track of the trip type
  late TimeOfDay time;
  late DateTime date;
  double chargePerKm = 5.0;

  TextEditingController tripName = TextEditingController();
  TextEditingController seatingCapacity = TextEditingController();

  @override
  void initState() {
    startLocation = '';
    endLocation = '';
    super.initState();
    time = TimeOfDay.now();
    date = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Create Trip", showicon: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            const Text(
              'ROUTE START POINT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectStartPoint,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      // Wrap the Text widget with Expanded
                      flex: 1, // Set flex property to 1
                      child: FittedBox(
                        fit: BoxFit.none,
                        child: Text(
                          startLocation.isNotEmpty
                              ? startLocation
                              : 'SELECT ROUTE START POINT',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: startLocation.isNotEmpty
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'ROUTE END POINT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectEndPoint,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1, // Set flex property to 1
                      child: Text(
                        endLocation.isNotEmpty
                            ? endLocation
                            : 'SELECT ROUTE END POINT',
                        style: TextStyle(
                            color: endLocation.isNotEmpty
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: tripName,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Trip Name';
                }
                // You can add additional validation rules here, such as checking for numeric input
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: seatingCapacity,
              decoration: const InputDecoration(
                labelText: 'Seating Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter seating capacity';
                }
                // You can add additional validation rules here, such as checking for numeric input
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${time.hour}:${time.minute}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Trip Type Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _setTripType('One Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        tripType == 'One Time' ? Colors.yellow : Colors.grey,
                  ),
                  child: const Text('One Time'),
                ),
                ElevatedButton(
                  onPressed: () => _setTripType('Daily'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        tripType == 'Daily' ? Colors.yellow : Colors.grey,
                  ),
                  child: const Text('Daily'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Background color
                foregroundColor: Colors.black, // Text Color (Foreground color)
              ),
              onPressed: () {
                _submitForm(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isProfileComplete() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get a reference to the document
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('driverDetails')
                .doc(user.uid) // Use the current user's UID as the document ID
                .get();

        // Check if the document exists
        bool isComplete = snapshot.exists;

        if (isComplete) {
          // Store profile information in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', user.uid);
          prefs.setString('userName', snapshot['name']);
          prefs.setString('phoneNumber', snapshot['phoneNumber']);
          prefs.setString('vehicleName', snapshot['vehicleName']);
          prefs.setString('vehicleNo', snapshot['vehicleNo']);
        }

        return isComplete;
      } else {
        // User not logged in
        return false;
      }
    } catch (error) {
      print('Error checking profile completeness: $error');
      return false; // Return false in case of any errors
    }
  }

  void _selectStartPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(),
      ),
    ).then((_) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      setState(() {
        startLocation =
            locationProvider.startAddress ?? 'SELECT ROUTE START POINT';
        print(startLocation);
      });
    });
  }

  void _selectEndPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(),
      ),
    ).then((_) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      setState(() {
        endLocation = locationProvider.endAddress ?? 'SELECT ROUTE END POINT';
        print(endLocation);
      });
    });
  }

  void _setTripType(String type) {
    setState(() {
      tripType = type;
    });
  }

  void _submitForm(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? phoneNumber = prefs.getString('phoneNumber');
    String? vehicleNo = prefs.getString('vehicleNo');

    final isProfileComplete =
        await _isProfileComplete(); // Check if the profile is complete
    if (isProfileComplete) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        // If the form is valid, submit the trip details
        FirebaseFirestoreService().submitTripToFirestore(
            context: context,
            startLocation: startLocation,
            endLocation: endLocation,
            tripName: tripName.text.toString(),
            seatingCapacity: seatingCapacity.text.toString(),
            tripType: tripType,
            date: date,
            time: time,
            chargePerKm: chargePerKm,
            vehicleNo: vehicleNo ?? "",
            contactNo: phoneNumber ?? "");
      }
    } else {
      // Show an alert if the user's profile is incomplete
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(
            'Profile Incomplete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red, // Title color
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oops! It seems like your profile is incomplete.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Content color
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Please complete your profile before creating a trip.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Content color
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Button color
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (pickedTime != null && pickedTime != time) {
      setState(() {
        time = pickedTime;
      });
    }
  }
}

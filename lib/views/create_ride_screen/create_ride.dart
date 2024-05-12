import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/location/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../location/provider/location_provider.dart';

class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  late String startLocation;
  late String endLocation;
  final _formKey = GlobalKey<FormState>();
  String tripName = '';
  int seatingCapacity = 0;
  String tripType = 'One Time'; // Variable to keep track of the trip type
  late TimeOfDay time;
  late DateTime date;
  double chargePerKm = 5.0;

  @override
  void initState() {
    startLocation = '';
    endLocation = '';
    super.initState();
    time = TimeOfDay.now();
    date = DateTime.now();
  }

  Future<void> submitTripToFirestore({
    required String startLocation,
    required String endLocation,
    required String tripName,
    required int seatingCapacity,
    required String tripType,
    required DateTime date,
    required TimeOfDay time,
    required double chargePerKm,
  }) async {
    try {
      // Your Firestore logic to store trip information
      await FirebaseFirestore.instance.collection('trips').add({
        'startLocation': startLocation,
        'endLocation': endLocation,
        'tripName': tripName,
        'seatingCapacity': seatingCapacity,
        'tripType': tripType,
        'date': date,
        'time': time,
        'chargePerKm': chargePerKm,
      });
      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear form fields after successful submission
      setState(() {
        startLocation = '';
        endLocation = '';
        tripName = '';
        seatingCapacity = 0;
        tripType = 'One Time';
        time = TimeOfDay.now();
        date = DateTime.now();
        chargePerKm = 5.0;
      });
    } catch (error) {
      // Handle error if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create trip: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    FittedBox(
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
                    Text(
                      endLocation.isNotEmpty
                          ? endLocation
                          : 'SELECT ROUTE END POINT',
                      style: TextStyle(
                          color: endLocation.isNotEmpty
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => tripName = value!,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Seating Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
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
                submitTripToFirestore(
                    startLocation: startLocation,
                    endLocation: endLocation,
                    tripName: tripName,
                    seatingCapacity: seatingCapacity,
                    tripType: tripType,
                    date: date,
                    time: time,
                    chargePerKm: chargePerKm);
              },
            ),
          ],
        ),
      ),
    );
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
            locationProvider.getStartAddress ?? 'SELECT ROUTE START POINT';
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
        endLocation =
            locationProvider.getEndAddress ?? 'SELECT ROUTE END POINT';
        print(endLocation);
      });
    });
  }

  void _setTripType(String type) {
    setState(() {
      tripType = type;
    });
  }

  void _submitForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      // Use the tripName, seatingCapacity, tripType, and chargePerKm for submission
      print('Trip Name: $tripName');
      print('Seating Capacity: $seatingCapacity');
      print('Trip Type: $tripType');
      print('Charge per Km: $chargePerKm');

      // Implement the rest of the submission logic here
    }
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

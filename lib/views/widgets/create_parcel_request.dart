import 'package:flutter/material.dart';

import '../location/location_screen.dart';

class ParcelRequest extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<ParcelRequest> {
  final _formKey = GlobalKey<FormState>();
  String tripName = '';
  int seatingCapacity = 0;
  String tripType = 'One Time'; // Variable to keep track of the trip type
  late TimeOfDay time;
  late DateTime date;
  double chargePerKm = 5.0;

  // Define startLocation and endLocation variables here
  String startLocation = '';
  String endLocation = '';
  @override
  void initState() {
    super.initState();
    time = TimeOfDay.now();
    date = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dilver Parcel'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            ListTile(
              title: const Text('ROUTE START POINT'),
              subtitle: const Text('SELECT ROUTE START POINT'),
              leading: const Icon(Icons.location_on, color: Colors.green),
              onTap: () => _selectStartPoint(),
            ),
            ListTile(
              title: const Text('ROUTE END POINT'),
              subtitle: const Text('SELECT ROUTE END POINT'),
              leading: const Icon(Icons.location_on, color: Colors.red),
              onTap: () => _selectEndPoint(),
            ),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Parcel Type',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => tripName = value!,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            const SizedBox(height: 24),
            // Trip Type Buttons
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Background color
                foregroundColor: Colors.black, // Text Color (Foreground color)
              ),
              onPressed: _submitForm,
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
    ).then((selectedLocation) {
      if (selectedLocation != null) {
        setState(() {
          startLocation = selectedLocation;
        });
      }
    });
  }

  void _selectEndPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(),
      ),
    ).then((selectedLocation) {
      if (selectedLocation != null) {
        setState(() {
          endLocation = selectedLocation;
        });
      }
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
}

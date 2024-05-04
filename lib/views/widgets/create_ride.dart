import 'package:flutter/material.dart';

class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  String tripName = '';
  int seatingCapacity = 0;
  String tripType = 'One Time'; // Variable to keep track of the trip type
  late TimeOfDay time;
  late DateTime date;
  double chargePerKm = 5.0;

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
        title: Text('Create Trip'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            ListTile(
              title: Text('ROUTE START POINT'),
              subtitle: Text('SELECT ROUTE START POINT'),
              leading: Icon(Icons.location_on, color: Colors.green),
              onTap: () => _selectStartPoint(),
            ),
            ListTile(
              title: Text('ROUTE END POINT'),
              subtitle: Text('SELECT ROUTE END POINT'),
              leading: Icon(Icons.location_on, color: Colors.red),
              onTap: () => _selectEndPoint(),
            ),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => tripName = value!,
            ),
            SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Seating Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),

              keyboardType: TextInputType.number,
              onSaved: (value) => seatingCapacity = int.tryParse(value!) ?? 0,
            ),
            SizedBox(height: 24),
            // Trip Type Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _setTripType('One Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tripType == 'One Time' ? Colors.yellow : Colors.grey,
                  ),
                  child: Text('One Time'),
                ),
                ElevatedButton(
                  onPressed: () => _setTripType('Daily'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tripType == 'Daily' ? Colors.yellow : Colors.grey,
                  ),
                  child: Text('Daily'),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Create'),
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
    // Implement start point selection
  }

  void _selectEndPoint() {
    // Implement end point selection
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
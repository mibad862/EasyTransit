import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/common_widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  final String driverName;
  final String carType;
  final String pickUp;
  final String dropOff;
  final DateTime date;
  final DateTime time;
  final String seatCapacity;
  final String documentId;

  const BookingPage({
    Key? key,
    required this.documentId,
    required this.driverName,
    required this.carType,
    required this.pickUp,
    required this.dropOff,
    required this.date,
    required this.time,
    required this.seatCapacity,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int maleCount = 0;
  int femaleCount = 0;
  int kidsCount = 0;
  late SharedPreferences prefs;
  String? userID;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid');
    });
  }

  void _saveBookingDetails(
      BuildContext context, String name, String contactNumber) async {
    if (userID == null) {
      CustomSnackbar.show(
          context, "User ID is not available", SnackbarType.error);
      return;
    }

    try {
      // Reference to the Firestore collection
      CollectionReference tripRequests =
          FirebaseFirestore.instance.collection('Trip requests');

      // Store the booking details in Firestore
      await tripRequests.doc(widget.documentId).set({
        'name': name,
        'contactNumber': contactNumber,
        'maleCount': maleCount,
        'femaleCount': femaleCount,
        'kidsCount': kidsCount,
      });

      CollectionReference tripBooked =
          FirebaseFirestore.instance.collection('trip_booked');

      // Store the booking details in Firestore using user UUID as document ID
      await tripBooked.doc(userID).set({
        'name': name,
        'contactNumber': contactNumber,
        'maleCount': maleCount,
        'femaleCount': femaleCount,
        'kidsCount': kidsCount,
        'driverName': widget.driverName,
        'carType': widget.carType,
        'pickUp': widget.pickUp,
        'dropOff': widget.dropOff,
        'date': widget.date,
        'time': widget.time,
        'seatCapacity': widget.seatCapacity,
      });

      // Show success message
      CustomSnackbar.show(
          context,
          "Your ride request has been successfully submitted",
          SnackbarType.success);

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      // Show error message if something went wrong
      CustomSnackbar.show(context, "Error: $e", SnackbarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Ride Booking", showicon: true),
      body: Column(
        children: <Widget>[
          // Map section (dummy container for illustration)
          Container(
            height: 149.0,
            width: 500,
            child: Center(
              child: SizedBox(
                width: 500,
                height: 300,
                child: Image.asset(
                  'assets/images/map.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Form section
          Expanded(
            child: ListView(
              children: <Widget>[
                const ListTile(
                  title: Text('Trip Type'),
                  trailing: Text('Daily'),
                ),
                ListTile(
                  title: const Text('Departure Time'),
                  trailing: Text(DateFormat.jm()
                      .format(widget.time)), // Format DateTime to String
                ),
                ListTile(
                  title: const Text('Seating Capacity'),
                  trailing: Text(widget.seatCapacity.toString()),
                ),
                ListTile(
                  title: const Text('Available Capacity'),
                  trailing: Text(widget.seatCapacity.toString()),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Contact No'),
                  // trailing: Text(widget.contactNo ?? 'N/A'),
                ),
                const ListTile(
                  title: Text('Vehicle No'),
                  // trailing: Text(widget.vehicleNo ?? 'N/A'),
                ),
                const Divider(),
                CounterWidget(
                  label: 'Male',
                  count: maleCount,
                  onIncrement: () => _incrementCount('male'),
                  onDecrement: () => _decrementCount('male'),
                ),
                CounterWidget(
                  label: 'Female',
                  count: femaleCount,
                  onIncrement: () => _incrementCount('female'),
                  onDecrement: () => _decrementCount('female'),
                ),
                CounterWidget(
                  label: 'Kids',
                  count: kidsCount,
                  onIncrement: () => _incrementCount('kids'),
                  onDecrement: () => _decrementCount('kids'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _requestBooking(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                    child: const Text('Request Booking'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _incrementCount(String gender) {
    setState(() {
      if (gender == 'male')
        maleCount++;
      else if (gender == 'female')
        femaleCount++;
      else if (gender == 'kids') kidsCount++;
    });
  }

  void _decrementCount(String gender) {
    setState(() {
      if (gender == 'male' && maleCount > 0)
        maleCount--;
      else if (gender == 'female' && femaleCount > 0)
        femaleCount--;
      else if (gender == 'kids' && kidsCount > 0) kidsCount--;
    });
  }

  void _requestBooking(BuildContext context) {
    String name = '';
    String contactNumber = '';

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter Your Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
              placeholder: 'Name',
              onChanged: (value) {
                name = value;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              placeholder: 'Contact Number',
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                contactNumber = value;
              },
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              if (name.isNotEmpty && contactNumber.isNotEmpty) {
                // Proceed with booking logic
                _saveBookingDetails(context, name, contactNumber);
                // Close the dialog only once
                Navigator.of(context).pop();
              } else {
                // Show error if name or contact number is empty
                CustomSnackbar.show(
                    context,
                    "Please enter your name and contact number",
                    SnackbarType.error);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class CounterWidget extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  CounterWidget({
    required this.label,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrement,
          ),
          Text('$count'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

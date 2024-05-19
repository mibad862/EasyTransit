import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/widgets/ride_book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideViewScreen extends StatelessWidget {
  DateTime _parseTimeString(String timeString) {
    // Split the time string into hours and minutes
    List<String> parts = timeString.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Assuming the time is in 24-hour format, create a DateTime object with today's date
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hours, minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Find a Ride", showicon: true),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('trips').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (BuildContext context, int index) {
              final trip = trips[index];
              return rideOption(
                context,
                documentId: trip.id,
                driverName: trip['UserName'],
                carType: trip['tripName'],
                pickUp: trip['startLocation'],
                dropOff: trip['endLocation'],
                time: _parseTimeString(trip["time"]),
                date: (trip["date"] as Timestamp).toDate(),
                seatCapacity: trip['seatingCapacity'].toString(),
                contactNo: trip['contactNo'].toString(),
                vehicleNo: trip['vehicleNo'].toString(),
              );
            },
          );
        },
      ),
    );
  }
}

Widget rideOption(
  BuildContext context, {
  required String documentId, // Add document ID parameter

  required String driverName,
  required String carType,
  required String pickUp,
  required String dropOff,
  required DateTime date,
  required DateTime time,
  required String seatCapacity,
  required contactNo,
  required vehicleNo,
}) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(driverName),
          subtitle: Text(carType),
          trailing: ElevatedButton(
            child: const Text('BOOK NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(
                    documentId: documentId,
                    driverName: driverName,
                    carType: carType,
                    pickUp: pickUp,
                    dropOff: dropOff,
                    date: date,
                    time: time,
                    seatCapacity: seatCapacity,
                    contactNo: contactNo,
                    vehicleNo: vehicleNo,
                  ), // Correct usage of constructor
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('PICK UP:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(pickUp)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('DROP OFF:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(dropOff)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(Icons.chair, color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  const Text('Seating Capacity:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(seatCapacity)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(Icons.date_range_outlined,
                      color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  const Text('Trip Date:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(DateFormat.yMd().format(date))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(Icons.alarm, color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  const Text('Trip Time:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(DateFormat.jm().format(time))),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

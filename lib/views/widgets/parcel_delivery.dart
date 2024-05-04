import 'package:demo_project1/views/widgets/ride_book.dart';
import 'package:flutter/material.dart';

class ParcelDelivery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parcel Deliver View'),
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
      body: ListView(
        children: <Widget>[
          rideOption(
            context,

            driverName: 'Muhammad Akram',
            carType: '03145044373',
            pickUp: 'CB 51/4 Gudwal Rd, Wah, Rawalpindi, Punjab, Pakistan',
            dropOff: 'P3CW+F8R, G-5/2 G-5, Islamabad, Islamabad Capital Territory, Pakistan',
            distance: 'cloth',
            weight: '1kg',
          ),
          rideOption(
            context,
            driverName: 'Uzair Raja',
            carType: '03056655008',
            pickUp: 'Bilal Street Gadwal 26 Area Rd, Shah Wali Colony, Wah, Rawalpindi, Punjab, Pakistan',
            dropOff: 'P26R+524, F-8 Markaz F 8 Markaz F-8, Islamabad, Islamabad Capital Territory, Pakistan',
            distance: 'cloth',
            weight: '1kg',
          ),

          // ... other ride options ...
        ],
      ),
    );
  }

  Widget rideOption(BuildContext context, {required String driverName, required String carType, required String pickUp, required String dropOff, required String distance, required String weight}) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(driverName),
            subtitle: Text(carType),
            trailing: ElevatedButton(
              child: Text('BOOK NOW'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>BookingPage (), // Correct usage of constructor
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('PICK UP'),
                Text(pickUp),
                SizedBox(height: 8.0),
                Text('DROP OFF'),
                Text(dropOff),
                SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    // Icon(Icons.location_on),
                    Text(distance),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

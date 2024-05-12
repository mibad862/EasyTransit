import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/bus_schedule/bus_schedule.dart';
import 'package:demo_project1/views/emergency_screen.dart/emergency_service.dart';
import 'package:demo_project1/views/passenger_section/passenger_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_firestore_services.dart';
import '../create_ride_screen/create_ride.dart';
import '../parcel_delivery_screen/parcel_delivery.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen(
      {super.key}); // Added to manage the current index of the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    const yellowGradient = LinearGradient(
      colors: [Colors.yellow, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );

    return Scaffold(
      appBar: const CommonAppBar(title: "Driver Screen", showicon: false),
      drawer: FutureBuilder(
        future: FirebaseFirestoreService().getUserInformation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              // Handle error if fetching data fails
              return Text('Error: ${snapshot.error}');
            } else {
              final userInformation = snapshot.data;
              return Drawer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: yellowGradient,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          gradient: yellowGradient,
                        ),
                        accountName: Text(
                          userInformation?.name ?? "", // User's display name
                          style: const TextStyle(color: Colors.black),
                        ),
                        accountEmail: Text(
                          userInformation?.email ?? "", // User's email
                          style: const TextStyle(color: Colors.black),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            userInformation != null &&
                                    userInformation.name != null &&
                                    userInformation.name!.isNotEmpty
                                ? userInformation.name![0]
                                    .toUpperCase() // Ensure name is not null or empty
                                : "", // Display nothing if name is null or empty
                            style:
                                // ignore: prefer_const_constructorss
                                TextStyle(fontSize: 40.0, color: Colors.white),
                          ),
                        ),
                      ),
                      _createDrawerItem(
                          icon: Icons.home,
                          text: 'Home',
                          onTap: () => Navigator.pop(context)),
                      _createDrawerItem(
                          icon: Icons.receipt,
                          text: 'Trip Requests',
                          onTap: () => Navigator.pop(context)),
                      _createDrawerItem(
                        icon: Icons.exit_to_app,
                        text: 'Logout',
                        onTap: () {
                          FirebaseAuth.instance.signOut().then((_) {
                            Navigator.pop(context); // Close the drawer
                            Navigator.pushReplacementNamed(
                                context, '/login'); // Navigate to login screen
                          }).catchError((error) {
                            print("Error signing out: $error");
                            // Handle error if any
                          });
                        },
                      ),
                      _createDrawerItem(
                          icon: Icons.security,
                          text: 'Privacy Policy',
                          onTap: () => Navigator.pop(context)),
                      SwitchListTile(
                        title: const Text('Driver Mode'),
                        value: false, // this should be a state variable
                        onChanged: (bool value) {
                          // Update the state of the app
                          if (value) {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => PassengerScreen(),
                            ));
                          } else {
                            // Handle turning off Passenger Mode
                          }
                        },
                        secondary: const Icon(Icons.directions_car),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),

      body: buildBody(context), // Use a separate method for the body
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget buildBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      childAspectRatio: 1.2,
      children: [
        _createBoxItem(
          text: 'Ride Share',
          imgPath: "assets/images/3d-car.png",
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => HomePage(),
            //   ),
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTripPage(),
              ),
            );
          },
        ),
        _createBoxItem(
          text: 'Parcel Delivery',
          imgPath: "assets/images/3d-truck.png",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParcelDelivery(),
              ),
            );
            // Handle the action for Parcel Delivery
          },
        ),
        _createBoxItem(
          text: 'Emergency Service',
          imgPath: "assets/images/ambulance.png",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmergencyServicePage(),
              ),
            );
            // Handle the action for Emergency Service
          },
        ),
        _createBoxItem(
          text: 'Bus Schedule',
          imgPath: "assets/images/van.png",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BusSchedulePage(),
              ),
            );
            // Handle the action for Bus Schedule
          },
        ),
      ],
    );
  }

  Widget _createBoxItem(
      {required String text,
      required String imgPath,
      required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imgPath,
              fit: BoxFit.cover,
              height: 50,
            ),
            const SizedBox(height: 8.0),
            FittedBox(
              fit: BoxFit.none,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

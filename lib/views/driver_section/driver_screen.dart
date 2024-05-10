import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/bus_schedule/bus_schedule.dart';
import 'package:demo_project1/views/emergency_screen.dart/emergency_service.dart';
import 'package:demo_project1/views/widgets/parcel_delivery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../passenger_section/passenger_screen.dart'; // Import the passenger screen file
import '../widgets/create_ride.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen(
      {super.key}); // Added to manage the current index of the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;

    return Scaffold(
      appBar: const CommonAppBar(title: "Driver Screen", showicon: false),
      drawer: buildDrawer(context), // Use a separate method for the drawer
      body: buildBody(context), // Use a separate method for the body
      bottomNavigationBar: BottomNavigationBar(
        // Add the bottom navigation bar
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle item tap to navigate to different sections
          if (index == 0) {
            // Navigate to the home section
            Navigator.pop(context);
          } else if (index == 1) {
            // Navigate to the rating section (you can replace this with your own logic)
            // Navigator.push(...);
          } else if (index == 2) {
            // Navigate to the profile section (you can replace this with your own logic)
            // Navigator.push(...);
          }
        },
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
              accountName: Text(
                "Shaheryar",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black, // Set text color to black
                ),
              ),
              accountEmail: Text(
                "sharyarhanif2865@gmail.com",
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  'S',
                  style: TextStyle(fontSize: 40.0, color: Colors.white),
                ),
              ),
            ),
            _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                onTap: () => Navigator.pop(context)),
            _createDrawerItem(
                icon: Icons.add_circle,
                text: 'Create Trip',
                onTap: () => Navigator.pop(context)),
            _createDrawerItem(
                icon: Icons.receipt,
                text: 'Trip Requests',
                onTap: () => Navigator.pop(context)),
            _createDrawerItem(
                icon: Icons.edit,
                text: 'Edit Profile',
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
              title: const Text('Passenger Mode'),
              value: false, // this should be a state variable
              onChanged: (bool value) {
                // Update the state of the app
                if (value) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const PassengerScreen(),
                  ));
                } else {
                  // Handle turning off Passenger Mode
                }
              },
              secondary: const Icon(Icons.person),
            ),
          ],
        ),
      ),
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
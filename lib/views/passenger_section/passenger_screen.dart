import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/services/firebase_firestore_services.dart';
import 'package:demo_project1/views/dilver_parcel_screen/create_parcel_request.dart';
import 'package:demo_project1/views/driver_section/driver_mainscreen.dart';
import 'package:demo_project1/views/ride_view_screen/ride_view_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/webview_screen.dart';
import '../booked_trip_screen/booked_trip_screen.dart';
import '../chat_screen/chat_screen.dart';
import '../emergency_screen.dart/emergency_service.dart';
import '../privacy_policy/privacy_policy_screen.dart';

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  PassengerScreenState createState() => PassengerScreenState();
}

class PassengerScreenState extends State<PassengerScreen> {
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

  @override
  Widget build(BuildContext context) {
    const yellowGradient = LinearGradient(
      colors: [Colors.yellow, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );

    return Scaffold(
      appBar: const CommonAppBar(
        title: "Passenger Screen",
        showicon: false,
      ),
      drawer: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              // Handle error if fetching data fails
              return Text('Error: ${snapshot.error}');
            } else {
              final userInformation = snapshot.data;
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('userName', userInformation!.name!);
              });

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
                        text: 'Booked Trips',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const BookedTripsScreen()),
                        ),
                      ),
                      // Navigator.of(context).push(MaterialPageRoute(
                      //   builder: (context) =>
                      //       const TripRequestsScreen(),
                      // ))),
                      _createDrawerItem(
                        icon: Icons.exit_to_app,
                        text: 'Logout',
                        onTap: () {
                          // Clear SharedPreferences
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.clear();
                          });

                          // Sign out Firebase user
                          FirebaseAuth.instance.signOut().then((_) {
                            Navigator.pop(context); // Close the drawer
                            Navigator.pushReplacementNamed(context,
                                '/welcome'); // Navigate to login screen
                          }).catchError((error) {
                            print("Error signing out: $error");
                            // Handle error if any
                          });
                        },
                      ),

                      _createDrawerItem(
                          icon: Icons.security,
                          text: 'Privacy Policy',
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(),
                              ))),
                      SwitchListTile(
                        title: const Text('Driver Mode'),
                        value: false, // this should be a state variable
                        onChanged: (bool value) {
                          // Update the state of the app
                          if (value) {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => DriverMainScreen(),
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
        future: FirebaseFirestoreService().getUserInformation(),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 1.2,
        children: [
          _createBoxItem(
            text: 'Ride Book',
            imgPath: "assets/images/3d-car.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RideViewScreen(), // Correct usage of constructor
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
                  builder: (context) =>
                      ParcelRequest(), // Correct usage of constructor
                ),
              );
              // Handle the action for Parcel Delivery
            },
          ),
          // _createBoxItem(
          //   text: 'Location',
          //   imgPath: "assets/images/3d-car.png",
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) =>
          //             LocationScreen(), // Correct usage of constructor
          //       ),
          //     );
          //     // Handle the action for Parcel Delivery
          //   },
          // ),

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
            text: 'View Bus Schedule',
            imgPath: "assets/images/van.png",
            onTap: () {
              Navigator.push(
                  context,
                  // MaterialPageRoute(
                  //   builder: (context) => BusSchedulePage(),
                  // ),
                  MaterialPageRoute(builder: (context) => WebViewScreen()));
              // Handle the action for View Bus Schedule
            },
          ),
          _createBoxItem(
            text: 'Chat Screen',
            imgPath: "assets/images/chat-message-icon.png",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen()));
            },
          ),
        ],
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
}

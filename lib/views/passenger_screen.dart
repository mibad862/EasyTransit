import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/bus_schedule/bus_schedule.dart';
import 'package:demo_project1/views/dilver_parcel_screen/create_parcel_request.dart';
import 'package:demo_project1/views/driver_screen.dart';
import 'package:demo_project1/views/ride_view_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/emergency_service.dart';

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  PassengerScreenState createState() => PassengerScreenState();
}

class PassengerScreenState extends State<PassengerScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Example: Home screen
    RatingScreen(), // Example: Rating screen
    ProfileScreen(), // Example: Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    final yellowGradient = const LinearGradient(
      colors: [Colors.yellow, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );

    return Scaffold(
      appBar: const CommonAppBar(
        title: "Passenger Screen",
        showicon: false,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: yellowGradient,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: yellowGradient,
                ),
                accountName: const Text(
                  "shaheryar hanif",
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
                accountEmail: const Text(
                  "sharyarhanif2865@gmail.com",
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
                currentAccountPicture: const CircleAvatar(
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
                  onTap: () => Navigator.pop(context)),
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const DriverScreen(),
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
                MaterialPageRoute(
                  builder: (context) => BusSchedulePage(),
                ),
              );
              // Handle the action for View Bus Schedule
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rating',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        onTap: _onItemTapped,
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Screen Content',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RatingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Rating Screen Content',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Screen Content',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

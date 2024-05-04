import 'package:flutter/material.dart';
import 'passenger_screen.dart'; // Import the passenger screen file
import 'driver_screen.dart'; // Import the driver screen file

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set background color to transparent
      body: Stack( // Use Stack to overlay the background image and content
        children: [
          // Background image
          Image.asset(
            'assets/images/easyTransit.png', // Replace with your image asset path
            fit: BoxFit.cover, // Cover the entire screen with the image
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Spacer(),
                Spacer(),
                Spacer(),
                Spacer(),
                Text(
                  'Use App As',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        // Handle Passenger button press
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PassengerScreen(),
                        ));
                      },
                      child: Container( // Wrap text in a container to set fixed width
                        width: 120, // Adjust the width as needed
                        alignment: Alignment.center,
                        child: Text('PASSENGER'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle Driver button press
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DriverScreen(), // Navigate to DriverScreen
                        ));
                      },
                      child: Container( // Wrap text in a container to set fixed width
                        width: 120, // Adjust the width as needed
                        alignment: Alignment.center,
                        child: Text('DRIVER'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

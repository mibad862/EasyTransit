import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0; // Initial opacity set to 0 for fade-in effect

  @override
  void initState() {
    super.initState();
    // Start the fade-in animation after the desired delay
    Timer(Duration(milliseconds: 20), () {
      setState(() {
        opacity = 1.0;
      });
    });

    // Navigate to the next screen after some delay
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedOpacity(
        opacity: opacity,
        duration: Duration(seconds: 3), // Duration of the fade in animation
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/easyTransit.png'), // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

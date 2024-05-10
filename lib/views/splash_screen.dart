import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // Check if the current user is null
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // If user is null, navigate to the welcome screen
        Timer(Duration(seconds: 4), () {
          Navigator.pushReplacementNamed(context, '/welcome');
        });
      } else {
        // If user is not null, navigate to the home screen
        Timer(Duration(seconds: 4), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
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
              image: AssetImage(
                  'assets/images/easyTransit.png'), // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

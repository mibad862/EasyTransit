import 'package:flutter/material.dart';

class CreateRideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ride'),
      ),
      body: Center(
        child: Text(
          'This is the Create Ride screen.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

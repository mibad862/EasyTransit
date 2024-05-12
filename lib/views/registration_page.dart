import 'package:demo_project1/home_screen.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'E-Mail',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      _signUp(context);
                    },
                    child: Text('SIGN UP'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Already Have an Account? Sign in',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _signUp(BuildContext context) {
  // Your implementation for Sign Up goes here

  // Simulate a successful sign-up for demonstration purposes
  bool isSignUpSuccessful = true;

  if (isSignUpSuccessful) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content:
              Text('User added successfully!'), // Your success message here
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:demo_project1/common_widgets/custom_snackbar.dart';
import 'package:demo_project1/common_widgets/custom_text_field.dart';
import 'package:demo_project1/home_screen.dart';
import 'package:demo_project1/views/widgets/custom_email_textfield.dart';
import 'package:demo_project1/views/widgets/custom_password_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/common_bottom_headline.dart';
import '../../utils/field_validator.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  EmailLoginScreenState createState() => EmailLoginScreenState();
}

class EmailLoginScreenState extends State<EmailLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isVisible = false;
  bool isSubmit = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> storeUserProfile(String user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('userid', user);

      print(prefs.getString('userid'));
      print("User ID: ");
    } catch (error) {
      print('Error storing user profile: $error');
      throw error;
    }
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      isSubmit = true; // Set to true to show loading indicator
    });

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isSubmit = false; // Reset to false if validation fails
      });
      return;
    }
    _formKey.currentState!.save();

    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      final String userid = user!.uid;

      // Check if user is approved
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userid).get();
      if (userDoc.exists && userDoc['status'] == 'approved') {
        // User is approved, proceed to home screen
        storeUserProfile(userid);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // User is not approved, show a message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Your account is on pending approval by Admin.'),
        ));
      }
    } on FirebaseAuthException catch (error) {
      // Handle different authentication errors
      String errorMessage = error.code.toString();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    } finally {
      setState(() {
        isSubmit = false; // Reset to false after authentication attempt
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.020),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.150),
                    child: const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 30.0, color: Colors.black),
                    ),
                  ),
                  const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                  SizedBox(
                    height: screenHeight * 0.050,
                  ),
                  CustomEmailTextField(
                    emailController: emailController,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(
                    height: screenHeight * 0.008,
                  ),
                  CustomPasswordTextField(
                    screenHeight: screenHeight,
                    passController: passController,
                    validator: FieldValidator.validatePassword,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Forgot Password"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Enter your email to receive a password reset link.",
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    controller: emailController,
                                    labelText: "Email Address",
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Handle the password reset logic
                                      try {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                          email: emailController.text,
                                        );
                                        Navigator.pop(context);

                                        CustomSnackbar.show(
                                            context,
                                            'Password Reset Email Sent',
                                            SnackbarType.success);
                                      } catch (e) {
                                        CustomSnackbar.show(
                                            context,
                                            'Failed to send reset email',
                                            SnackbarType.error);
                                      }
                                    },
                                    child: const Text("Reset Password"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  CommonElevatedButton(
                    buttonColor: Colors.purple,
                    fontSize: 15,
                    height: screenHeight * 0.065,
                    width: double.infinity,
                    onPressed: () {
                      _submit(context);
                    },
                    text: isSubmit ? 'Logging In....' : 'Login',
                  ),
                  SizedBox(
                    height: screenHeight * 0.210,
                  ),
                  const CommonBottomHeadline(
                    navigationPath: '/signup',
                    text1: "Don't have an account?",
                    text2: "Sign Up",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

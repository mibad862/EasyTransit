import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:demo_project1/views/home_screen.dart';
import 'package:demo_project1/views/widgets/custom_email_textfield.dart';
import 'package:demo_project1/views/widgets/custom_password_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> _submit() async {
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

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgotten password?',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                  CommonElevatedButton(
                    buttonColor: Colors.purple,
                    fontSize: 15,
                    height: screenHeight * 0.065,
                    width: double.infinity,
                    onPressed: _submit,
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

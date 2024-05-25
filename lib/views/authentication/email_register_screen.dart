import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/common_bottom_headline.dart';
import '../../utils/field_validator.dart';
import '../verify_email/verify_email.dart';
import '../widgets/custom_email_textfield.dart';
import '../widgets/custom_password_textfield.dart';

final _firebase = FirebaseAuth.instance;

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController nameController = TextEditingController(); // Changed to non-static
  bool isPassVisible = false;
  bool isConfirmPassVisible = false;
  bool isSubmit = false;

  final _formKey = GlobalKey<FormState>();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

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
      await _firebase.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      await users.doc(userCredential.user!.uid).set({
        'full_name': nameController.text.toString(),
        'email': emailController.text.toString(),
        'status': 'pending', // Add status field with 'pending' value
      });

      // Save the user's full name locally using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', nameController.text.toString());

      // Navigate to the EmailVerificationScreen
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmailVerificationScreen()));
    } on FirebaseAuthException catch (error) {
      String errorMessage = error.code.toString();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Firestore error: ${error.message}"),
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
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.040),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.100),
                      child: const Text(
                        "Let's get started",
                        style: TextStyle(fontSize: 30.0, color: Colors.black),
                      ),
                    ),
                    const Text(
                      'Create your new account',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    ),
                    SizedBox(
                      height: screenHeight * 0.050,
                    ),
                    _nameTextField(screenHeight),
                    SizedBox(
                      height: screenHeight * 0.008,
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
                    SizedBox(
                      height: screenHeight * 0.008,
                    ),
                    CustomPasswordTextField(
                      screenHeight: screenHeight,
                      passController: confirmPassController,
                      validator: (value) {
                        return FieldValidator.validateConfirmPassword(
                            value, passController.text);
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.018,
                    ),
                    CommonElevatedButton(
                      buttonColor: Colors.purple,
                      fontSize: 15,
                      height: screenHeight * 0.065,
                      width: double.infinity,
                      onPressed: _submit,
                      text: isSubmit ? "Creating..." : "Create account",
                    ),
                    SizedBox(
                      height: screenHeight * 0.130,
                    ),
                    const CommonBottomHeadline(
                      navigationPath: '/ulogin',
                      text1: "Already have an account",
                      text2: "Sign In",
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField(double screenHeight) {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      validator: FieldValidator.validateFullname,
      controller: nameController,
      decoration: InputDecoration(
        prefixIconColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.030),
        hintText: "Full Name",
        prefixIcon: const Icon(Icons.person),
      ),
    );
  }
}

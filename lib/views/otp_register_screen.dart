import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../common_widgets/common_elevated_button.dart';
import 'otp_screen.dart';

class OTPRegisterScreen extends StatefulWidget {
  const OTPRegisterScreen({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<OTPRegisterScreen> {
  final  phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isInputValid = false;

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: _buildBackgroundDecoration(),
      child: Scaffold(
        appBar: _buildAppBar(screenWidth),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.085),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIllustration(screenHeight, screenWidth),
                    SizedBox(height: screenHeight * 0.005),
                    _buildRegistrationText(screenWidth),
                    SizedBox(height: screenHeight * 0.010),
                    _buildDescriptionText(screenWidth),
                    SizedBox(height: screenHeight * 0.040),
                    _buildForm(screenHeight, screenWidth, context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 239, 255, 99),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.arrow_back,
          size: screenWidth * 0.080,
          color: Colors.black54,
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 239, 255, 99),
          Color.fromARGB(255, 232, 231, 161),
        ],
      ),
    );
  }

  Widget _buildIllustration(double screenHeight, double screenWidth) {
    return Image.asset(
      'assets/images/illustration-2.png',
      height: screenHeight * 0.370,
      width: screenWidth * 0.370,
      fit: BoxFit.contain,
    );
  }

  Widget _buildRegistrationText(double screenWidth) {
    return Text(
      'Registration',
      style: TextStyle(
        fontSize: screenWidth * 0.060,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescriptionText(double screenWidth) {
    return Text(
      "Add your phone number. We'll send you a verification code so we know you're real",
      style: TextStyle(
        fontSize: screenWidth * 0.040,
        fontWeight: FontWeight.bold,
        color: Colors.black38,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildForm(
      double screenHeight, double screenWidth, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.040,
        vertical: screenHeight * 0.040,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              setState(() {
                isInputValid = value.length == 10;
              });
            },
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: screenHeight * 0.020),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              prefix: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '(+92)',
                  style: TextStyle(
                    fontSize: screenWidth * 0.050,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              suffixIcon: Icon(
                Icons.check_circle,
                color: isInputValid ? Colors.green : Colors.grey,
                size: screenWidth * 0.070,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length != 10) {
                return 'Phone number should be 10 digits';
              }
              return null;
            },
            maxLength: 10,
          ),
          SizedBox(height: screenHeight * 0.030),
          CommonElevatedButton(
            fontSize: screenWidth * 0.045,
            borderRadius: 24.0,
            width: screenWidth * 0.750,
            height: screenHeight * 0.065,
            buttonColor: Colors.purple,
            textColor: Colors.white,
            onPressed: () async {
              final phoneController = '+92${phoneNumberController.text.trim()}';
              await FirebaseAuth.instance.verifyPhoneNumber(
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException ex) {},
                  codeSent: (String verificationid, int? resendtoken) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OtpScreen(verificationId: verificationid)));
                  },
                  codeAutoRetrievalTimeout: (String verificationid) {},
                  phoneNumber: phoneController);
            },
            text: "Send",
          ),
        ],
      ),
    );
  }
}

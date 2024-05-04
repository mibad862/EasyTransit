import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:demo_project1/views/otp_screen.dart';
import 'package:flutter/material.dart';

class OTPRegisterScreen extends StatefulWidget {
  const OTPRegisterScreen({required Key key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<OTPRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _buildAppBar(screenWidth),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: _buildBackgroundDecoration(),
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.085),
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
      "Add your phone number. we'll send you a verification code so we know you're real",
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
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '(+92)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              suffixIcon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.030),
          CommonElevatedButton(
            fontSize: screenWidth * 0.045,
            borderRadius: 24.0,
            width: screenWidth * 0.750,
            height: screenHeight * 0.065,
            buttonColor: Colors.purple,
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  key: UniqueKey(),
                ),
              ),
            ),
            text: "Send",
          ),
        ],
      ),
    );
  }
}

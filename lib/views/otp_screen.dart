import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../common_widgets/common_elevated_button.dart';
import '../home_screen.dart';

class OtpScreen extends StatefulWidget {
  OtpScreen({super.key, required this.verificationId});

  String verificationId;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final otpController = TextEditingController();
    final focusNode = FocusNode();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.blue),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(
                255, 239, 255, 99), // Change these colors to your preference
            Color.fromARGB(255, 232, 231, 161),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 239, 255, 99),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: screenWidth * 0.080,
              color: Colors.black54,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.040),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/illustration-3.png',
                  height: screenHeight * 0.240,
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.020),
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.020),
                const Text(
                  "Enter your OTP code number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.030),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Pinput(
                        controller: otpController,
                        focusNode: focusNode,

                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsRetrieverApi,
                        length: 6,

                        listenForMultipleSmsOnAndroid: true,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        // validator: (value) {
                        //   return value == '2222' ? null : 'Pin is incorrect';
                        // },
                        // onClipboardFound: (value) {
                        //   debugPrint('onClipboardFound: $value');
                        //   pinController.setText(value);
                        // },
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('onCompleted: $pin');
                        },
                        onChanged: (value) {
                          debugPrint('onChanged: $value');
                        },
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
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
                        onPressed: () async {
                          try {
                            PhoneAuthCredential credential =
                                await PhoneAuthProvider.credential(
                                    verificationId: widget.verificationId,
                                    smsCode: otpController.text.toString());

                            FirebaseAuth.instance
                                .signInWithCredential(credential)
                                .then((value) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen())));
                          } catch (ex) {
                            print(ex.toString());
                          }
                        },
                        text: "Verify",
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                const Text(
                  "Didn't you receive any code?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.020),
                const Text(
                  "Resend New Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

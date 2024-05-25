import 'package:flutter/material.dart';

import '../../utils/field_validator.dart';


class CustomEmailTextField extends StatelessWidget {
  const CustomEmailTextField({
    super.key,
    required this.emailController,
    required this.screenHeight,
  });

  final TextEditingController emailController;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      validator: FieldValidator.validateEmail,
      controller: emailController,
      decoration: InputDecoration(
        prefixIconColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
        hintText: "Email Address",
        prefixIcon: const Icon(Icons.email),
      ),
    );
  }
}
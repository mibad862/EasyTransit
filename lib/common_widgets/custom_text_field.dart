import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Validation function

  const CustomTextField({
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator, // Validator parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator, // Assign the validator function
    );
  }
}

import 'package:flutter/material.dart';


class CustomPasswordTextField extends StatefulWidget {
  final double screenHeight;
  final TextEditingController passController;
  final String? Function(String?)? validator;

  const CustomPasswordTextField({
    super.key,
    required this.screenHeight,
    required this.passController,
    required this.validator,
  });

  @override
  CustomPasswordTextFieldState createState() => CustomPasswordTextFieldState();
}

class CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool isPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      obscureText: !isPassVisible,
      controller: widget.passController,
      decoration: InputDecoration(
        prefixIconColor: Colors.black,
        suffixIconColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding:
        EdgeInsets.symmetric(vertical: widget.screenHeight * 0.030),
        hintText: "Password",
        prefixIcon: const Icon(Icons.key),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPassVisible = !isPassVisible;
            });
          },
          icon: isPassVisible
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
      ),
    );
  }
}
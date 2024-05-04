import 'package:flutter/material.dart';

class CommonElevatedButton extends StatelessWidget {
  const CommonElevatedButton({
    super.key, // Corrected key definition
    required this.onPressed,
    this.height,
    this.width,
    required this.text,
    this.textColor,
    this.buttonColor,
    this.fontSize,
    this.borderRadius,
    this.buttonElevation,
  }); // Corrected super constructor call

  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final double? buttonElevation;

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      elevation: buttonElevation ?? 0.0,
      borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
      color: Colors.transparent, // Set color to transparent
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
        onTap: onPressed,
        child: Container(
          height: height ?? screenHeight * 0.050,
          width: width ?? screenWidth * 0.2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
            color: buttonColor ?? Colors.red,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: fontSize ?? screenWidth * 0.020,
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
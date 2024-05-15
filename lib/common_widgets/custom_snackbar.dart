import 'package:flutter/material.dart';

enum SnackbarType { success, error }

class CustomSnackbar {
  static void show(BuildContext context, String message, SnackbarType type) {
    Color backgroundColor;
    IconData iconData;
    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red;
        iconData = Icons.error_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              iconData,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

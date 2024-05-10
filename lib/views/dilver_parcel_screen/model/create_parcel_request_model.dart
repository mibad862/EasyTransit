import 'package:flutter/material.dart';


class ParcelRequestModel extends ChangeNotifier {
  String startLocation = '';
  String endLocation = '';
  String tripName = '';
  int weight = 0;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String tripType = 'One Time';
  double chargePerKm = 5.0;

  void setStartLocation(String location) {
    startLocation = location;
    notifyListeners();
  }

  void setEndLocation(String location) {
    endLocation = location;
    notifyListeners();
  }

  // Implement setters for other properties as needed
}

import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String? startAddress;
  String? endAddress;

  void setStartAddress(String address) {
    startAddress = address;
    notifyListeners(); // Notify listeners of state change
  }

  void setEndAddress(String address) {
    endAddress = address;
    notifyListeners(); // Notify listeners of state change
  }

  String? get getStartAddress {
    return startAddress;
  }

  String? get getEndAddress {
    return endAddress;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

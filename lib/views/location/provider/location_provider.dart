import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String? _startAddress;
  String? _endAddress;

  String? get startAddress => _startAddress;
  String? get endAddress => _endAddress;

  void setStartAddress(String address) {
    _startAddress = address;
    notifyListeners();
  }

  void setEndAddress(String address) {
    _endAddress = address;
    notifyListeners();
  }

  void clearAddresses() {
    _startAddress = null;
    _endAddress = null;
    notifyListeners();
  }
}

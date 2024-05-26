import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:demo_project1/services/firebase_firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';

class EmergencyServicePage extends StatefulWidget {
  const EmergencyServicePage({super.key});

  @override
  EmergencyServicePageState createState() => EmergencyServicePageState();
}

class EmergencyServicePageState extends State<EmergencyServicePage> {
  final _formKey = GlobalKey<FormState>(); // Create a GlobalKey for the form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Added phone number controller

  DateTime? selectedDate; // Initialize selectedDate as null

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _phoneController.dispose(); // Dispose phone number controller

    super.dispose();
  }

  void _makePhoneCall() async {
    // Placeholder emergency number - replace with actual emergency number
    const emergencyNumber = '1122';
    final Uri emergencyUri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(emergencyUri)) {
      await launchUrl(emergencyUri);
    } else {
      throw 'Could not launch $emergencyNumber';
    }
  }

  void _preBookAmbulance() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      // Implement pre-booking logic
      print('Pre-booking ambulance for:');
      print('Name: ${_nameController.text}');
      print('Phone: ${_phoneController.text}'); // Print the phone number
      print('Location: ${_locationController.text}');
      print('Time: ${_timeController.text}');
      print('Date: $selectedDate'); // Print the selected date

      FirebaseFirestoreService().storeAmbulanceBooking(
        context,
        _nameController.text,
        _locationController.text,
        _timeController.text,
        selectedDate!,
        _phoneController.text, // Pass the phone number
      );

      _nameController.clear();
      _locationController.clear();
      _timeController.clear();
      _phoneController.clear(); // Clear the phone number field
    }
  }

  Future<void> _getCurrentLocation() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    // Check if location services are enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    _locationData = await location.getLocation();

    // Get the address from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      _locationData.latitude!,
      _locationData.longitude!,
    );

    // If available, get the first address
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address = "${place.street}, ${place.locality}, ${place.country}";
      _locationController.text = address;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const CommonAppBar(title: "Emergency Service", showIcon: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Attach the form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonElevatedButton(
                  buttonElevation: 2.0,
                  fontSize: 14,
                  borderRadius: 15.0,
                  width: screenWidth * 0.420,
                  height: screenHeight * 0.055,
                  buttonColor: Colors.red,
                  onPressed: _makePhoneCall,
                  text: "Call Ambulance",
                ),
                SizedBox(height: screenHeight * 0.040),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _phoneController, // Added phone number field
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Current Location',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed:
                      _getCurrentLocation, // Updated to call the method
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                              : 'Select Date',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Desired Time for Ambulance',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    // Prevent Keyboard from appearing
                    FocusScope.of(context).requestFocus(new FocusNode());
                    // Show Time Picker Here
                    final TimeOfDay? pickedTime = await showTimePicker(
                      initialTime: TimeOfDay.now(),
                      context: context,
                    );
                    if (pickedTime != null) {
                      _timeController.text = pickedTime.format(context);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the desired time for the ambulance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.040),
                CommonElevatedButton(
                  buttonElevation: 2.0,
                  borderRadius: 16.0,
                  buttonColor: Colors.amber,
                  textColor: Colors.black,
                  fontSize: 15,
                  height: screenHeight * 0.060,
                  width: screenWidth * 0.580,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _preBookAmbulance();

                      Navigator.pop(context);
                    }
                  },
                  text: 'Pre-Book Ambulance',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate; // Update the selectedDate variable
      });
    }
  }
}

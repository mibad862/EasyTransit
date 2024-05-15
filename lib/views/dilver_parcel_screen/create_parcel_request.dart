import 'package:demo_project1/views/location/provider/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/custom_text_field.dart';
import '../../services/firebase_firestore_services.dart';
import '../location/location_screen.dart';

class ParcelRequest extends StatefulWidget {
  @override
  _ParcelRequestState createState() => _ParcelRequestState();
}

class _ParcelRequestState extends State<ParcelRequest> {
  final _formKey = GlobalKey<FormState>();
  late String tripName;
  late int seatingCapacity;
  late String tripType;
  late TimeOfDay time;
  late DateTime date;
  late double chargePerKm;
  late String startLocation;
  late String endLocation;
  late TextEditingController tripNameController;
  late TextEditingController seatingCapacityController;
  late TextEditingController sendersNumberController;
  late TextEditingController receiversNumberController;

  @override
  void initState() {
    super.initState();
    time = TimeOfDay.now();
    date = DateTime.now();
    tripType = 'One Time';
    startLocation = '';
    endLocation = '';
    tripName = '';
    seatingCapacity = 0;
    chargePerKm = 5.0;
    tripNameController = TextEditingController();
    seatingCapacityController = TextEditingController();
    sendersNumberController = TextEditingController();
    receiversNumberController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Dilver Parcel',
        showicon: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROUTE START POINT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectStartPoint,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: Text(
                              startLocation.isNotEmpty
                                  ? startLocation
                                  : 'SELECT ROUTE START POINT',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: startLocation.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ROUTE END POINT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectEndPoint,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Text(
                            endLocation.isNotEmpty
                                ? endLocation
                                : 'SELECT ROUTE END POINT',
                            style: TextStyle(
                                color: endLocation.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  labelText: 'Sender\'s Number',
                  controller: sendersNumberController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Recevier\'s Number',
                  controller: receiversNumberController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  labelText: 'Parcel Type',
                  controller: tripNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Weight',
                  controller: seatingCapacityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Parcel Type is required';
                    }
                    return null; // Return null if validation succeeds
                  },
                ),
                const SizedBox(height: 16),
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
                          '${date.year}-${date.month}-${date.day}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${time.hour}:${time.minute}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                      ),
                      child: const Text('Create'),
                    ),
                  ),
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
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (pickedTime != null && pickedTime != time) {
      setState(() {
        time = pickedTime;
      });
    }
  }

  void _selectStartPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(),
      ),
    ).then((_) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      setState(() {
        startLocation =
            locationProvider.getStartAddress ?? 'SELECT ROUTE START POINT';
        print(startLocation);
      });
    });
  }

  void _selectEndPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(),
      ),
    ).then((_) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      setState(() {
        endLocation =
            locationProvider.getEndAddress ?? 'SELECT ROUTE END POINT';
        print(endLocation);
      });
    });
  }

  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');
      if (userName != null && userName.isNotEmpty) {
        FirebaseFirestoreService().storeParcelRecord(
          context,
          tripNameController.text,
          int.tryParse(seatingCapacityController.text) ?? 0,
          tripType,
          chargePerKm,
          date,
          time,
          startLocation,
          endLocation,
          userName, // Pass the retrieved user name
          sendersNumberController.text.toString(),
          receiversNumberController.text.toString(),
        );
      } else {
        // Handle case where user name is not available in SharedPreferences
        print('User name not available');
      }
    }
  }
}

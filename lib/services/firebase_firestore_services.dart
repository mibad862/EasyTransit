import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> storeParcelRecord(
      BuildContext context,
      String tripName,
      int seatingCapacity,
      String tripType,
      double chargePerKm,
      DateTime date,
      TimeOfDay time,
      String startLocation,
      String endLocation) async {
    try {
      // Convert TimeOfDay to String representation
      String formattedTime = '${time.hour}:${time.minute}';
      String? userId = _auth.currentUser?.uid;

      CollectionReference userCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('parcelRecords');

      userCollection.add({
        'tripName': tripName,
        'seatingCapacity': seatingCapacity,
        'tripType': tripType,
        'chargePerKm': chargePerKm,
        'date': date,
        'time': formattedTime, // Store formatted time
        'startLocation': startLocation,
        'endLocation': endLocation,
      });
      print('Parcel record added successfully');
      CustomSnackbar.show(
          context, 'Parcel record added successfully', SnackbarType.success);
    } catch (e) {
      print('Error adding parcel record: $e');
      CustomSnackbar.show(
          context, 'Error adding parcel record', SnackbarType.error);
    }
  }

  Future<void> storeAmbulanceBooking(
    BuildContext context,
    String name,
    String location,
    String time,
  ) async {
    try {
      String? userId = _auth.currentUser?.uid;

      CollectionReference userCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('ambulanceBookings');

      userCollection.add({
        'name': name,
        'location': location,
        'time': time,
      });
      print('Ambulance booking added successfully');
      CustomSnackbar.show(context, 'Ambulance booking added successfully',
          SnackbarType.success);
    } catch (e) {
      print('Error adding ambulance booking: $e');
      CustomSnackbar.show(
          context, 'Error adding ambulance booking', SnackbarType.error);
    }
  }
}

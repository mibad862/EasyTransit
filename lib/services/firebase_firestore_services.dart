import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_snackbar.dart';
import 'package:flutter/material.dart';

class FirebaseFirestoreService {
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

      await FirebaseFirestore.instance.collection('parcelRecords').add({
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
      CustomSnackbar.show(context, 'Parcel record added successfully', SnackbarType.success);

    } catch (e) {
      print('Error adding parcel record: $e');
            CustomSnackbar.show(context, 'Error adding parcel record', SnackbarType.error);

    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/custom_snackbar.dart';
import 'package:demo_project1/views/passenger_section/model/user_info_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> storeBookedParcel(
      String docId, Map<String, dynamic> parcelData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      await _db.collection('booked_parcels').doc(userId).set({
        ...parcelData,
        'documentId': docId, // Save the document ID
      });
    } else {
      throw Exception('User is not logged in');
    }
  }

  Future<void> storeParcelRecord(
    BuildContext context,
    String tripName,
    int seatingCapacity,
    String tripType,
    double chargePerKm,
    DateTime date,
    TimeOfDay time,
    String startLocation,
    String endLocation,
    String userName,
    String senderNumber,
    String receiverNumber,
    double fare,
  ) async {
    try {
      // Convert TimeOfDay to String representation
      String formattedTime = '${time.hour}:${time.minute}';
      String? userId = _auth.currentUser?.uid;

      CollectionReference userCollection =
          _firestore.collection('parcelRecords');

      userCollection.add({
        'userName': userName,
        'senderNumber': senderNumber,
        'recevierNumber': receiverNumber,
        'tripName': tripName,
        'seatingCapacity': seatingCapacity,
        'tripType': tripType,
        'chargePerKm': chargePerKm,
        'date': date,
        'time': formattedTime, // Store formatted time
        'startLocation': startLocation,
        'endLocation': endLocation,
        'fare': fare
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

  Future<void> storeTripRecord(
    BuildContext context,
    String tripName,
    int seatingCapacity,
    String tripType,
    double chargePerKm,
    DateTime date,
    TimeOfDay time,
    String startLocation,
    String endLocation,
    String userName,
  ) async {
    try {
      // Convert TimeOfDay to String representation
      String formattedTime = '${time.hour}:${time.minute}';
      String? userId = _auth.currentUser?.uid;

      CollectionReference userCollection = _firestore.collection('TripRecords');

      userCollection.add({
        'userName': userName,
        'tripName': tripName,
        'seatingCapacity': seatingCapacity,
        'tripType': tripType,
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

  Future<List<Map<String, dynamic>>> getParcelRecords() async {
    String? userId = _auth.currentUser?.uid;

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("parcelRecords").get();

      List<Map<String, dynamic>> parcelRecords = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['documentId'] = doc.id; // Add the documentId to the map
        return data;
      }).toList();

      print(parcelRecords);

      return parcelRecords;
    } catch (e) {
      print('Error fetching parcel records: $e');
      throw e; // Rethrow the error for handling in UI
    }
  }

  Future<Map<String, dynamic>> getBookedParcel() async {
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    DocumentSnapshot docSnapshot =
        await _firestore.collection('booked_parcels').doc(userId).get();

    if (!docSnapshot.exists) {
      throw Exception('No booked parcels found for this user');
    }

    return docSnapshot.data() as Map<String, dynamic>;
  }

  Future<void> storeAmbulanceBooking(
    BuildContext context,
    String name,
    String location,
    String time,
    DateTime date, // Initialize date variable
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
        'date': date,
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

  Future<UserInformationModel?> getUserInformation() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          final data = snapshot.data();
          final String? name = data?['full_name'];
          final String? email = data?['email'];

          // Store user information in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', name ?? '');
          await prefs.setString('userEmail', email ?? '');

          return UserInformationModel(name: name, email: email);
        } else {
          // If document doesn't exist, fallback to Firebase user data
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', user.displayName ?? '');
          await prefs.setString('userEmail', user.email ?? '');

          return UserInformationModel(
              name: user.displayName, email: user.email);
        }
      } catch (error) {
        print('Error fetching user information: $error');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> submitTripToFirestore({
    required BuildContext context,
    required String startLocation,
    required String endLocation,
    required String tripName,
    required String seatingCapacity,
    required String tripType,
    required DateTime date,
    required TimeOfDay time,
    required double chargePerKm,
    required String contactNo,
    required String vehicleNo,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');
      String? userId = prefs.getString('userId'); // Ensure userId is stored in SharedPreferences
      DateTime adjustedDate = DateTime(date.year, date.month, date.day);

      if (userId == null) {
        throw Exception('User ID is not available.');
      }

      // Your Firestore logic to store trip information
      await FirebaseFirestore.instance.collection('trips').doc(userId).set({
        'UserName': userName,
        'startLocation': startLocation,
        'endLocation': endLocation,
        'tripName': tripName,
        'seatingCapacity': seatingCapacity,
        'tripType': tripType,
        'date': adjustedDate,
        'time': timeToString(time),
        'chargePerKm': chargePerKm,
        'contact no': contactNo,
        'vehicle no': vehicleNo
      });

      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      // Clear form fields after successful submission
    } catch (error) {
      // Handle error if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create trip: $error'),
          backgroundColor: Colors.red,
        ),
      );
      print(error.toString());
    }
  }

// Helper function to convert TimeOfDay to string
  String timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

}

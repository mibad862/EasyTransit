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
    String userid,
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
        'userId': userId,
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

   Future<void> storeBookedTrip({
    required BuildContext context,
    required String name,
    required String contactNumber,
    required int maleCount,
    required int femaleCount,
    required int kidsCount,
    required String driverName,
    required String carType,
    required String pickUp,
    required String dropOff,
    required DateTime date,
    required DateTime time,
    required String seatCapacity,
  }) async {
    try {
      // Reference to the Firestore collection
      CollectionReference tripBooked = _firestore.collection('trip_booked');

      // Store the booking details in Firestore using user UUID as document ID
      await tripBooked.doc(_auth.currentUser!.uid).set({
        'name': name,
        'contactNumber': contactNumber,
        'maleCount': maleCount,
        'femaleCount': femaleCount,
        'kidsCount': kidsCount,
        'driverName': driverName,
        'carType': carType,
        'pickUp': pickUp,
        'dropOff': dropOff,
        'date': date,
        'time': time,
        'seatCapacity': seatCapacity,
      });

      // Show success message
      CustomSnackbar.show(
        context,
        "Your ride request has been successfully submitted",
        SnackbarType.success,
      );

    } catch (e) {
      // Show error message if something went wrong
      CustomSnackbar.show(context, "Error: $e", SnackbarType.error);
    }
  }

  Future<void> storeAmbulanceBooking(
      BuildContext context,
      String name,
      String location,
      String time,
      DateTime date,
      String phoneNumber, // Added phone number parameter
      ) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        CustomSnackbar.show(context, 'User not logged in', SnackbarType.error);
        return;
      }

      DocumentReference userDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('ambulanceBookings')
          .doc(userId);

      await userDoc.set({
        'userId': userId,
        'name': name,
        'location': location,
        'time': time,
        'date': date,
        'phoneNumber': phoneNumber, // Added phone number field
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ambulance booking request submitted for approval',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error adding ambulance booking',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    required String userid,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');
      String? userId = prefs
          .getString('userId'); // Ensure userId is stored in SharedPreferences
      DateTime adjustedDate = DateTime(date.year, date.month, date.day);

      if (userId == null) {
        throw Exception('User ID is not available.');
      }

      // Your Firestore logic to store trip information
      await FirebaseFirestore.instance.collection('trips').doc(userId).set({
        'UserName': userName,
        'userId': userId,
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

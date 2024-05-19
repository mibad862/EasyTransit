import 'package:demo_project1/common_widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

import '../../../services/firebase_firestore_services.dart';

class ParcelOption extends StatelessWidget {
  final String docId;
  final String tripName;
  final String sender;
  final String receiver;
  final String startLocation;
  final String endLocation;
  final double fare;

  const ParcelOption({
    Key? key,
    required this.docId,
    required this.tripName,
    required this.sender,
    required this.receiver,
    required this.startLocation,
    required this.endLocation,
    required this.fare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final record = {
      'tripName': tripName,
      'senderNumber': sender,
      'receiverNumber': receiver,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'fare': fare,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripName,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Row(
                      children: [
                        Text(
                          'Fare: $fare',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text('Sender: $sender'),
                        Text('Receiver: $receiver'),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.6),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(context, docId, record);
                      },
                      child: const Text(
                        'Book Parcel',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('START LOCATION'),
                            Text(
                              startLocation,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('END LOCATION'),
                            Text(
                              endLocation,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String docId, Map<String, dynamic> record) {
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Are you sure you want to book this parcel?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog

                  // Store the booked parcel in Firestore
                  try {
                    await FirebaseFirestoreService()
                        .storeBookedParcel(docId, record);

                    // Show success message
                    CustomSnackbar.show(
                      context,
                      "Parcel has been Booked Successfully",
                      SnackbarType.success,
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }
}

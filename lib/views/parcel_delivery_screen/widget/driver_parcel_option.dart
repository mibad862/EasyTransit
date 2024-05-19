import 'package:demo_project1/views/parcel_delivery_screen/confirm_parcel_screen.dart';
import 'package:flutter/material.dart';

Widget parcelOption(
  BuildContext context, {
  required String tripName,
  required String sender,
  required String receiver,
  required String startLocation,
  required String endLocation,
  required double fare,
}) {
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
          // ListTile(
          //   contentPadding: const EdgeInsets.all(0),
          //   title: Text(
          //     tripName,
          //     style: Theme.of(context).textTheme.headline6,
          //   ),
          //   subtitle: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const SizedBox(height: 8.0),
          //       Text('Sender: $sender'),
          //       Text('Receiver: $receiver'),
          //     ],
          //   ),
          //   trailing: Column(
          //     children: [
          //       Text('Fare: $fare'),
          //       SizedBox(
          //         height: 10,
          //       ),
          //       ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.green.withOpacity(0.6),
          //         ),
          //         onPressed: () {
          //           _showConfirmationDialog(context, record);
          //         },
          //         child: const Text(
          //           'Book Parcel',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

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
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                      _showConfirmationDialog(context, record);
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
    BuildContext context, Map<String, dynamic> record) {
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
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmParcelScreen(record: record),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

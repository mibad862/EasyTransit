import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class ConfirmParcelScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  ConfirmParcelScreen({required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Parcel Confirmation", showicon: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record['tripName'],
              style: Theme.of(context).textTheme.headline5?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(
                context, 'Sender', record['senderNumber'], Icons.person),
            _buildDetailRow(context, 'Receiver', record['receiverNumber'],
                Icons.person_outline),
            _buildDetailRow(context, 'Start Location', record['startLocation'],
                Icons.location_on, Colors.red),
            _buildDetailRow(context, 'End Location', record['endLocation'],
                Icons.location_on, Colors.green),
            const SizedBox(height: 24.0),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      sendMessage(record, context); // Implement this function
                    },
                    child: const Text(
                      'Send Message',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon,
      [Color iconColor = Colors.black]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8.0),
          Text(
            '$label: ',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(Map<String, dynamic> record, BuildContext context) {
    // Implement your message sending functionality here
    // For example, using Firebase Firestore or Firebase Messaging
    // FirebaseFirestoreService().sendMessageToParcelCreator(record);

    // Show a confirmation dialog or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent to sender.'),
      ),
    );
  }
}

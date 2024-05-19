import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/chat_screen/ChatDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfirmParcelScreen extends StatelessWidget {
  // final Map<String, dynamic> record;

  // ConfirmParcelScreen({
  //   required this.record});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CommonAppBar(title: "Booked Parcel", showicon: true),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("booked_parcels")
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            String docIdFromFirestore = snapshot.data!.id;
            var record = snapshot.data!;

            return Padding(
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
                  _buildDetailRow(context, 'Start Location',
                      record['startLocation'], Icons.location_on, Colors.red),
                  _buildDetailRow(context, 'End Location',
                      record['endLocation'], Icons.location_on, Colors.green),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.amberAccent)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              userName:
                                  "Hafeez", // Pass appropriate username if needed
                              userImage:
                                  "", // Pass appropriate userimage if needed
                              receiverID:
                                  docIdFromFirestore, // Pass docIdFromFirestore as receiverID
                              senderID: user!.uid ??
                                  "", // Pass user's uid as senderID
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Send a Message",
                        style: TextStyle(color: Colors.black),
                      )),
                  const SizedBox(height: 24.0),
                  // Your existing UI code for buttons
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
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
}

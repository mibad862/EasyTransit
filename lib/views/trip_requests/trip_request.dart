import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/common_appbar.dart';

class TripRequestsScreen extends StatefulWidget {
  const TripRequestsScreen({Key? key}) : super(key: key);

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Trip Requests", showicon: true),
      body: Container(
        color: Colors.grey[200], // Set background color
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Trip requests')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching data'),
              );
            } else {
              final tripRequests = snapshot.data!.docs;
              return ListView.builder(
                itemCount: tripRequests.length,
                itemBuilder: (context, index) {
                  final tripRequest = tripRequests[index];
                  final data = tripRequest.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16), // Add padding
                        leading: const CircleAvatar(
                          // Use CircleAvatar for profile image
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          'Name: ${data['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Contact: ${data['contactNumber']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildIconWithCount(
                                    Icons.male, data['maleCount']),
                                const SizedBox(width: 8),
                                _buildIconWithCount(
                                    Icons.female, data['femaleCount']),
                                const SizedBox(width: 8),
                                _buildIconWithCount(
                                    Icons.child_friendly, data['kidsCount']),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () {
                            _callContact(data['contactNumber']);
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildIconWithCount(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void _callContact(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

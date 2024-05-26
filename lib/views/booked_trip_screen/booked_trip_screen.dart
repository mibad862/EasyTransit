import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookedTripsScreen extends StatefulWidget {
  const BookedTripsScreen({super.key});

  @override
  _BookedTripsScreenState createState() => _BookedTripsScreenState();
}

class _BookedTripsScreenState extends State<BookedTripsScreen> {
  late SharedPreferences prefs;
  String? userID;
  Map<String, dynamic>? tripDetails;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid');
    });
    if (userID != null) {
      _fetchTripDetails();
    }
  }

  Future<void> _fetchTripDetails() async {
    if (userID != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('trip_booked')
          .doc(userID)
          .get();

      if (doc.exists) {
        setState(() {
          tripDetails = doc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Booked Trips", showIcon: true),
      body: tripDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text('Name'),
                      subtitle: Text(tripDetails?['name'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text('Contact Number'),
                      subtitle: Text(tripDetails?['contactNumber'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.drive_eta, color: Colors.orange),
                      title: const Text('Driver Name'),
                      subtitle: Text(tripDetails?['driverName'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.directions_car, color: Colors.red),
                      title: const Text('Trip Name'),
                      subtitle: Text(tripDetails?['carType'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.purple),
                      title: const Text('Pick Up'),
                      subtitle: Text(tripDetails?['pickUp'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.location_off, color: Colors.pink),
                      title: const Text('Drop Off'),
                      subtitle: Text(tripDetails?['dropOff'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.teal),
                      title: const Text('Date and Time'),
                      subtitle: Text(tripDetails?['time'] != null
                          ? (tripDetails!['time'] as Timestamp)
                              .toDate()
                              .toString()
                          : ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.event_seat, color: Colors.brown),
                      title: const Text('Seat Capacity'),
                      subtitle: Text(tripDetails?['seatCapacity'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.male, color: Colors.blue),
                      title: const Text('Male Count'),
                      subtitle:
                          Text(tripDetails?['maleCount'].toString() ?? '0'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.female, color: Colors.pink),
                      title: const Text('Female Count'),
                      subtitle:
                          Text(tripDetails?['femaleCount'].toString() ?? '0'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.child_care, color: Colors.amber),
                      title: const Text('Kids Count'),
                      subtitle:
                          Text(tripDetails?['kidsCount'].toString() ?? '0'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // ElevatedButton(
                  //     style: const ButtonStyle(
                  //         backgroundColor:
                  //             MaterialStatePropertyAll(Colors.amberAccent)),
                  //     onPressed: () {
                  //       // print(record['senderName']);
                  //       // print('reciver id');
                  //       // print(docIdFromFirestore);
                  //       // print('Senders id');

                  //       // print(user!.uid);

                  //       // Navigator.push(
                  //       //   context,
                  //       //   MaterialPageRoute(
                  //       //     builder: (context) => ChatDetailPage(
                  //       //       userName: username.isNotEmpty
                  //       //           ? username
                  //       //           : "Default Name", // Fallback to a default name
                  //       //       userImage:
                  //       //           'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAxL3JtNjA5LXNvbGlkaWNvbi13LTAwMi1wLnBuZw.png',
                  //       //       receiverID: docIdFromFirestore,
                  //       //       senderID: user!.uid,
                  //       //     ),
                  //       //   ),

                  //       // );
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => ChatDetailPage(
                  //             userName: username.isNotEmpty
                  //                 ? username
                  //                 : "Default Name", // Fallback to a default name
                  //             userImage: '',
                  //             receiverID: id,
                  //             senderID: user!.uid,
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     child: const Text(
                  //       "Send a Message",
                  //       style: TextStyle(color: Colors.black),
                  //     )),
                ],
              ),
            ),
    );
  }
}

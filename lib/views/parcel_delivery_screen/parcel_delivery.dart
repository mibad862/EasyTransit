import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/services/firebase_firestore_services.dart'; // Import your Firestore service
import 'package:flutter/material.dart';

import 'widget/driver_parcel_option.dart';

class ParcelDelivery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Parcel Delivery View", showicon: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirebaseFirestoreService()
            .getParcelRecords(), // Fetch parcel records from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching parcel records'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final record = snapshot.data![index];
                // Render parcel record widget here
                return parcelOption(context,
                    tripName: record['tripName'],
                    sender: record['senderNumber'],
                    receiver: record['recevierNumber'],
                    startLocation: record['startLocation'],
                    endLocation: record['endLocation'],
                    fare: record['fare']
                    
                    // Add more details as needed
                    );
              },
            );
          } else {
            return const Center(child: Text('No parcel records found'));
          }
        },
      ),
    );
  }
}

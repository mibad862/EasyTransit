import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DriverRidesHistory extends StatelessWidget {
  DriverRidesHistory({super.key});

  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {


    void _deleteRide(BuildContext context, String rideId) async {
      try {
        await FirebaseFirestore.instance.collection('trips').doc(rideId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ride: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void _updateRide(String rideId, String tripName, String startLocation, String endLocation, String tripType, String time, String date, int seatingCapacity) async {
      try {
        await FirebaseFirestore.instance.collection('trips').doc(rideId).update({
          'tripName': tripName,
          'startLocation': startLocation,
          'endLocation': endLocation,
          'tripType': tripType,
          'time': time,
          'date': Timestamp.fromDate(DateFormat.yMd().parse(date)),
          'seatingCapacity': seatingCapacity,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ride: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void _showUpdateDialog(BuildContext context, String rideId, Map<String, dynamic> rideData) {
      TextEditingController tripNameController = TextEditingController(text: rideData["tripName"]);
      TextEditingController startLocationController = TextEditingController(text: rideData["startLocation"]);
      TextEditingController endLocationController = TextEditingController(text: rideData["endLocation"]);
      TextEditingController seatingCapacityController = TextEditingController(text: rideData["seatingCapacity"].toString());

      String selectedTripType = rideData["tripType"];
      TimeOfDay selectedTime = TimeOfDay(
        hour: int.parse(rideData["time"].split(":")[0]),
        minute: int.parse(rideData["time"].split(":")[1]),
      );
      DateTime selectedDate = (rideData["date"] as Timestamp).toDate();

      TextEditingController dateController = TextEditingController(text: DateFormat.yMd().format(selectedDate));
      TextEditingController timeController = TextEditingController(text: selectedTime.format(context));

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update Ride'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: tripNameController,
                    decoration: InputDecoration(labelText: 'Trip Name'),
                  ),
                  TextField(
                    controller: startLocationController,
                    decoration: InputDecoration(labelText: 'Start Location'),
                  ),
                  TextField(
                    controller: endLocationController,
                    decoration: InputDecoration(labelText: 'End Location'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTripType,
                    items: ["One Time", "Daily"]
                        .map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    ))
                        .toList(),
                    onChanged: (value) {
                      selectedTripType = value!;
                    },
                    decoration: InputDecoration(labelText: 'Trip Type'),
                  ),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(labelText: 'Time'),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        selectedTime = pickedTime;
                        timeController.text = selectedTime.format(context);
                      }
                    },
                    readOnly: true,
                  ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                        dateController.text = DateFormat.yMd().format(selectedDate);
                      }
                    },
                    readOnly: true,
                  ),
                  TextField(
                    controller: seatingCapacityController,
                    decoration: InputDecoration(labelText: 'Seating Capacity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateRide(
                    rideId,
                    tripNameController.text,
                    startLocationController.text,
                    endLocationController.text,
                    selectedTripType,
                    timeController.text,
                    dateController.text,
                    int.parse(seatingCapacityController.text),
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('userId', isEqualTo: userID) // Adjusted query to filter trips by userID
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No rides found.'),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 10),
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot rideDoc = snapshot.data!.docs[index];
              Map<String, dynamic> rideData =
              rideDoc.data() as Map<String, dynamic>;

              return Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rideData["tripName"],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 280,
                            child: Text(
                              maxLines: 2,
                              "Start Location: ${rideData["startLocation"]}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: Text(
                              maxLines: 2,
                              "End Location: ${rideData["endLocation"]}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Text(
                            "Trip Type: ${rideData["tripType"]}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "Time: ${rideData["time"]}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "Date: ${DateFormat.yMd().format((rideData["date"] as Timestamp).toDate())}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Seating Capacity: ${rideData["seatingCapacity"]}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _showUpdateDialog(context, rideDoc.id, rideData);
                            },
                            child: Icon(Icons.edit),
                          ),
                          InkWell(
                            onTap: () {
                              _deleteRide(context, rideDoc.id);
                            },
                            child: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

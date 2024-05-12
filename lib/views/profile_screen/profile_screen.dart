import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/common_widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common_widgets/common_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var size, height, width;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _vehiclenoController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  late String _avatarImagePath = ''; // Initialize _avatarImagePath here
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // Retrieve user profile data from Firestore

    getDiverdata();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarImagePath = pickedImage.path;
      });
    }
  }

  Future<void> getDiverdata() async {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('driverDetails')
          .doc(user?.uid)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.exists) {
          // If the document exists, set the text controllers with the existing data
          setState(() {
            _nameController.text = snapshot.data()?['name'] ?? '';
            _phonenoController.text = snapshot.data()?['phoneNumber'] ?? '';
            _vehicleNameController.text = snapshot.data()?['vehicleName'] ?? '';
            _vehiclenoController.text = snapshot.data()?['vehicleNo'] ?? '';
          });
        }
      }).catchError((error) {
        print('Error retrieving user profile data: $error');
      });
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        final uploadTask = storageRef.putFile(File(_avatarImagePath));
        final TaskSnapshot uploadSnapshot =
            await uploadTask.whenComplete(() {});

        // Get download URL of the uploaded image
        final imageUrl = await uploadSnapshot.ref.getDownloadURL();

        // Store profile information along with image URL in Firestore
        await FirebaseFirestore.instance
            .collection('driverDetails')
            .doc(user.uid)
            .set({
          'name': _nameController.text,
          'phoneNumber': _phonenoController.text,
          'vehicleName': _vehicleNameController.text,
          'vehicleNo': _vehiclenoController.text,
          'imageUrl': imageUrl, // Store image URL in Firestore
          // Add other fields as needed
        });

        CustomSnackbar.show(
            context, "Profile saved Successfully", SnackbarType.success);
      } catch (error) {
        CustomSnackbar.show(context, "Can't Update Profile Some error occurred",
            SnackbarType.error);
        print('Failed to save profile: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: const CommonAppBar(title: "My Profile", showicon: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 0.02 * height,
            ),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: SizedBox(
                  height: 0.2 * height,
                  child: CircleAvatar(
                    backgroundImage: _avatarImagePath.isNotEmpty
                        ? Image.file(File(_avatarImagePath)).image
                        : const AssetImage("assets/images/Avatar.png"),
                    radius: 60,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0.03 * width),
              child: Column(
                children: [
                  CustomTextField(
                    labelText: "Name",
                    controller: _nameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    labelText: "Phone no",
                    controller: _phonenoController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.length != 11) {
                        return 'Phone number must be 11 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    labelText: "Vehicle Name",
                    controller: _vehicleNameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    labelText: "Vehicle No",
                    controller: _vehiclenoController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 0.7 * width,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.amberAccent),
                      ),
                      onPressed: () {
                        _saveProfile(context);
                      },
                      child: const Text("Save"),
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
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/common_widgets/common_elevated_button.dart';
import 'package:demo_project1/common_widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common_widgets/custom_snackbar.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  DriverProfileScreenState createState() => DriverProfileScreenState();
}

class DriverProfileScreenState extends State<DriverProfileScreen> {
  var size, height, width;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _vehiclenoController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  late String _avatarImagePath = ''; // Initialize _avatarImagePath here
  User? user = FirebaseAuth.instance.currentUser;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Retrieve user profile data from Firestore
    getDriverData();
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

  Future<void> getDriverData() async {
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
        String? imageUrl;
        if (_avatarImagePath.isNotEmpty) {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          final uploadTask = storageRef.putFile(File(_avatarImagePath));
          final TaskSnapshot uploadSnapshot =
              await uploadTask.whenComplete(() {});

          // Get download URL of the uploaded image
          imageUrl = await uploadSnapshot.ref.getDownloadURL();
        }

        // Store profile information along with image URL in Firestore for approval
        await FirebaseFirestore.instance
            .collection('driverDetails')
            .doc(user.uid)
            .set({
          'name': _nameController.text,
          'phoneNumber': _phonenoController.text,
          'vehicleName': _vehicleNameController.text,
          'vehicleNo': _vehiclenoController.text,
          if (imageUrl != null) 'imageUrl': imageUrl,
          // Store image URL if available
          'status': 'pending',
          // Set initial status to pending
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          // Add other fields as needed
        });

        CustomSnackbar.show(context, "Profile submitted for approval by admin",
            SnackbarType.success);
      } catch (error) {
        CustomSnackbar.show(context, "Can't submit profile. An error occurred",
            SnackbarType.error);
        print('Failed to submit profile: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: const CommonAppBar(title: "My Profile", showIcon: false),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                margin: EdgeInsets.symmetric(horizontal: 0.04 * width),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: "Full Name",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      labelText: "Phone No.",
                      controller: _phonenoController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 11) {
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Vehicle Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      labelText: "Vehicle No.",
                      controller: _vehiclenoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Vehicle no';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.030),
                    CommonElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveProfile(context);
                        }
                      },
                      text: "Save",
                      buttonColor: Colors.amberAccent,
                      textColor: Colors.purple,
                      fontSize: 16,
                      width: 0.80 * width,
                      height: height * 0.060,
                      borderRadius: 15.0,
                      buttonElevation: 2.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

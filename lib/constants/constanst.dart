import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Constants {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? userId;

  Constants() {
    // Initialize userId in the constructor
    userId = _auth.currentUser?.uid;
  }
}

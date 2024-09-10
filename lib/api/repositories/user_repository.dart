import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection("users").snapshots();
  }

  Future getUserData( String? email) async {
    final CollectionReference firestoreRef = _firestore.collection('users');
    QuerySnapshot snapshot = await firestoreRef.where( // Return user information with this email from firestore
        "email", isEqualTo: email).get();
    return snapshot;
  }

  Future getUserById(String id) async {
    final CollectionReference firestore = _firestore.collection('users');
    Stream? snapshot = firestore.doc(id).snapshots();

    return snapshot;
  }
}

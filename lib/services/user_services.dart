import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  final String? userId;
  UserServices({this.userId});

  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");


  Future<QuerySnapshot<Map<String, dynamic>>> getFriendList() {
    return userCollection.doc(userId).collection('friends').get(); // Firestore don't know the length of a collection, so therefor return mother collection
  }




}


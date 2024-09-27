import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreGroups {
  final String? userId;
  FirestoreGroups({this.userId});

  final CollectionReference userCollection
    = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
    = FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection
    = FirebaseFirestore.instance.collection("friends");


  // Retriving user data
  Future getUserByEmail( String email) async {
    QuerySnapshot snapshot = await userCollection.where(
        "email", isEqualTo: email).get();
    return snapshot;
  }

  getGroupsList() {
    return userCollection.doc(userId).snapshots();
  }

  // Returning group admin of the custom groups
  Future getGroupAdmin (String groupId) async {
    DocumentReference docRef = groupCollection.doc(groupId);
    DocumentSnapshot docSnap = await docRef.get();
    return docSnap["admin"];
  }

  // group member of a custom group
  getGroupMember(groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  // Returning search result
  searchByGroupName(String groupName) {
    return groupCollection.where("name", isEqualTo: groupName).get();
  }

  // Returning search result
  searchByUserName(String username) {
    final splitted = username.split(' ');
    return userCollection.where("firstname", isEqualTo: splitted[0]).get();
  }





}

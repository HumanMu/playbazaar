import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../services/firestore_services.dart';


class FirestoreUser extends ChangeNotifier {
  final String? userId;
  FirestoreUser({this.userId});
  final _db = FirebaseFirestore.instance;

  List<UserModel> _userList = [];
  late UserModel _singleUser;
  late bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  List<UserModel> get multiUser => _userList;
  UserModel get singleUser => _singleUser;

  // reference to the firestore collection
  final CollectionReference userCollection =
    FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
    FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection =
    FirebaseFirestore.instance.collection("friends");

  void setIsEmailVerified(bool value) {
    _isEmailVerified = value;
    notifyListeners();
  }

  void listenToVerification() {
    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user != null) {
        setIsEmailVerified(user.emailVerified);
      }
    });
  }

  // Saving user data
  Future<bool> createUser(String fullname, String email ) async{
    return await FirestoreServices().createUser(
        fullname,
        email,
      FirebaseAuth.instance.currentUser!.uid);
  }

  // Saving user data
  Future<bool> editUserData(UserProfileModel data) async{
    return await FirestoreServices().editUserData(
        data,
        FirebaseAuth.instance.currentUser!.uid
    );
  }



  Future<void> getUserByEmail(String? email) async {
    _userList = await FirestoreServices().getUserByEmail(email);
    notifyListeners();
  }


  getOnlineState(String availabilityState) async{
    return await _db.collection('users').doc(userId).update({
      'availabilityState': availabilityState
    });
  }





  Future sendFriendRequest( String userId, String friendId) async {
    DocumentReference userDocRef =
    userCollection.doc(friendId).collection('friendRequests').doc(userId);
    DocumentSnapshot docSnap = await userDocRef.get();

    if(docSnap.exists) {
      await userDocRef.delete();
    }
    else {
      await FirestoreServices().saveFriend(friendId, userId, 'friendRequests');
    }
  }

  Future<int> getFriendRequestsLength() async {
    CollectionReference collectionRef = userCollection.doc(userId).collection('friendRequests');
    QuerySnapshot querySnapshot = await collectionRef.get();
    int requestsLength = querySnapshot.size;

    return requestsLength;
  }

  // Getting chat from a user
  getChat(String? friendId) async {
    return userCollection.doc(userId).collection("friends").doc(friendId)
        .collection('massages').orderBy("time").snapshots();
  }

  sendMessage(String? recieverId, Map<String, dynamic>chatMessageData ) async {
    await userCollection.doc(userId).collection('friends').doc(recieverId)
        .collection('massages').add(chatMessageData);
    await userCollection.doc(recieverId).collection('friends').doc(userId)
        .collection('massages').add(chatMessageData);
  }

}

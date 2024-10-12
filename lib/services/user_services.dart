import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../constants/constants.dart';
import '../functions/enum_converter.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';


class UserServices extends GetxService {
  final String? userId;
  UserServices({this.userId});
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  static UserServices get to => Get.find<UserServices>();
  DocumentSnapshot? lastDocument;

  Future<QuerySnapshot<Map<String, dynamic>>> getFriendList() {
    return userCollection.doc(userId).collection('friends').get();
  }

  Future<bool> sendFriendRequest( FriendModel request) async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    if(currentUserId == ""){
      if (kDebugMode) {
        print("Current user not found");
      }
      return false;
    }
    DocumentReference friendDocRef = userCollection.doc(request.uid).collection("receivedFriendRequests").doc(currentUserId);
    DocumentReference userDocRef = userCollection.doc(currentUserId).collection("sentFriendRequests").doc(request.uid);
    try{
      await userDocRef.set(request.toMap()); // saving to user collection
      // Saving to friends collection
      await friendDocRef.set({
        'uid': currentUserId,
        'fullname': firebaseAuth.currentUser?.displayName ??  "",
        'avatarImage': firebaseAuth.currentUser?.photoURL ?? "",
        'friendshipStatus': 'good',
      });
      return true;
    }catch(e){
      if (kDebugMode) {
        print("Sending friend request failed - service: $e");
      }
      return false;
    }
  }

  Future<bool> cancelFriendshipRequest(String friendId) async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    DocumentReference friendDocRef = userCollection.doc(friendId).collection("receivedFriendRequests").doc(currentUserId);
    DocumentReference userDocRef = userCollection.doc(currentUserId).collection("sentFriendRequests").doc(friendId);

    try{
      await friendDocRef.delete();
      await userDocRef.delete();
      return true;

    }catch(e){
      if (kDebugMode) {
        print("Failed to cancel friend request - service");
      }
      return false;
    }
  }

  Stream<List<FriendModel>> getRecievedFriendRequests(String userId) {
    return userCollection
        .doc(userId)
        .collection('receivedFriendRequests')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<FriendModel>> getSentFriendRequests(String userId) {
    return userCollection
        .doc(userId)
        .collection('sentFriendRequests')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendModel.fromFirestore(doc))
        .toList());
  }


  Future<QuerySnapshot> searchByUserName(String username, {int limit = 10}) async {
    String searchKey = username.toLowerCase();

    // Perform a range query to find names that start with the searchKey
    return await userCollection
        .where("fullname", isGreaterThanOrEqualTo: searchKey)
        .where("fullname", isLessThanOrEqualTo: '$searchKey\uf8ff')// For prefix search
        .limit(limit)
        .get();
  }


  Future<bool> acceptFriendRequest(String friendId) async {
    String ui = firebaseAuth.currentUser!.uid;
    DocumentReference userDocRef =  userCollection.doc(ui).collection('receivedFriendRequests').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('sentFriendRequests').doc(ui);
    DocumentSnapshot friendDocSnap = await friendDocRef.get();
    DocumentSnapshot userDocsnap = await userDocRef.get();

    try {
      if(userDocsnap.exists && friendDocSnap.exists){
        await userCollection.doc(ui).collection('friends').doc(friendId)
          .set(userDocsnap.data() as Map<String, dynamic>);
        await userCollection.doc(friendId).collection('friends').doc(ui)
            .set(userDocsnap.data() as Map<String, dynamic>);

        await userDocRef.delete();
        await friendDocRef.delete();
      }
      return false;
    }catch(e) {
      return false;
    }
  }

  Future<bool>declineFriendRequests(String friendId) async {
    String ui = firebaseAuth.currentUser!.uid;
    DocumentReference userDocRef =  userCollection.doc(ui).collection('receivedFriendRequests').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('sentFriendRequests').doc(ui);
      try{
        await userDocRef.delete();
        await friendDocRef.delete();
        return true;
      }catch(e){
        if (kDebugMode) {
          print("Error declining friend request: $e");
        }
        return false;
      }
  }



  Stream<UserModel?> getUserById(String userId) {
    return userCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        AccountCondition accountCondition = string2AccountCondition(doc['accountCondition']);
        UserRole role = string2UserRole(doc['role']);

        return UserModel(
          uid: doc['uid'],
          email: doc['email'],
          coins: doc['coins'],
          fullname: doc['fullname'],
          userPoints: doc['userpoints'],
          aboutme: doc['aboutme'],
          avatarImage: doc['avatarImage'],
          timestamp: doc['timestamp'],
          availabilityState: doc['availabilityState'],
          accountCondition: accountCondition,
          groupsId: List<String>.from(doc['groupsId'] ?? []),
          role: role,
        );
      }
      else {
        if (kDebugMode) {
          print("Document does not exist");
        }
        return null;
      }
    });
  }



}


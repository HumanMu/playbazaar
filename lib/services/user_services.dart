import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import 'private_message_service.dart';

class UserServices extends GetxService {
  final String? userId;
  UserServices({this.userId});
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference privateMessageCollection = FirebaseFirestore.instance.collection("privateMessages");
  final PrivateMessageService _privateMessageService = PrivateMessageService();
  DocumentSnapshot? lastDocument;


  Future<QuerySnapshot<Map<String, dynamic>>> getFriendList() {
    return userCollection.doc(userId).collection('friends').get();
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

  Stream<List<FriendModel>> getFriends(String userId) { // Not used yet
    return userCollection
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendModel.fromFirestore(doc))
        .toList());
  }


  Future<QuerySnapshot> searchByUserName(String username, {int limit = 10}) async {
    String searchKey = username.toLowerCase();
    return await userCollection
        .where("fullname", isGreaterThanOrEqualTo: searchKey)
        .where("fullname", isLessThanOrEqualTo: '$searchKey\uf8ff')// For prefix search
        .limit(limit)
        .get();
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
        'fullname': firebaseAuth.currentUser?.displayName?.toLowerCase() ??  "",
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


  Future<FriendModel?> acceptFriendRequest(String chatId, String friendId) async {
    String ui = firebaseAuth.currentUser!.uid;
    DocumentReference userDocRef =  userCollection.doc(ui).collection('receivedFriendRequests').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('sentFriendRequests').doc(ui);

    try {
      DocumentSnapshot userRequestSnapshot = await userDocRef.get();
      DocumentSnapshot friendRequestSnapshot = await friendDocRef.get();

      if (userRequestSnapshot.exists && friendRequestSnapshot.exists) {
        Map<String, dynamic> userData = userRequestSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> friendData = friendRequestSnapshot.data() as Map<String, dynamic>;

        // Add/update the chatId in both user and friend's data
        userData['chatId'] = chatId;
        friendData['chatId'] = chatId;

        await userCollection.doc(ui).collection('friends').doc(friendId).set(userData);
        await userCollection.doc(friendId).collection('friends').doc(ui).set(friendData);


        await userDocRef.delete();
        await friendDocRef.delete();

        return FriendModel.fromFirestore(friendRequestSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }

      return null;

    }catch(e) {
      return null;
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

  Future<bool>removeFriendById(String friendId) async {
    String ui = firebaseAuth.currentUser!.uid;
    DocumentReference userDocRef =  userCollection.doc(ui).collection('friends').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('friends').doc(ui);
    try{
      DocumentSnapshot docSnap = await friendDocRef.get();
      if (docSnap.exists && docSnap.data() != null) {
        await _privateMessageService.deletePrivateMessageCollection(docSnap['chatId']);
      }
      
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
        return UserModel.fromFirestore(doc);
      } else {
        if (kDebugMode) {
          print("Document does not exist");
        }
        return null;
      }
    });
  }



  Future<FriendModel?> getASingleFriendById(String currentUserId, String friendId) async {
    CollectionReference friendListRef = userCollection.doc(currentUserId).collection('friends');
    DocumentReference friendDoc = friendListRef.doc(friendId);

    try{
      final friendResult = await friendDoc.get();
      return FriendModel.fromFirestore(friendResult as DocumentSnapshot<Map<String, dynamic>>);
    }
    catch(e){
      return null;
    }
  }



}


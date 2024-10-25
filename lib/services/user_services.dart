import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import '../constants/constants.dart';
import '../functions/enum_converter.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';


class UserServices extends GetxService {
  final String? userId;
  UserServices({this.userId});
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference privateMessageCollection = FirebaseFirestore.instance.collection("privateMessages");
  //static UserServices get to => Get.find<UserServices>();
  DocumentSnapshot? lastDocument;


  /*RxList<FriendModel> friendList = <FriendModel>[].obs;
  RxList<FriendModel> receivedFriendRequests = <FriendModel>[].obs;
  RxList<FriendModel> sentFriendRequests = <FriendModel>[].obs;

  // Stream to get the friend list and store it reactively
  Stream<void> listenToFriendList(String uid) {
    return userCollection.doc(uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
          friendList.assignAll(
              snapshot.docs.map((doc) => FriendModel.fromFirestore(doc)).toList());
    });
  }

  Future<void> fetchFriendList(String uid) async {
    final snapshot = await userCollection.doc(uid).collection('friends').get();
    friendList.assignAll(snapshot.docs.map((doc) => FriendModel.fromFirestore(doc)).toList());
  }


  // Stream to get the received friend requests and store them reactively
  Stream<void> listenToReceivedFriendRequests(String uid) {
    print("Entered the listen recieved friends");
    return userCollection.doc(uid)
        .collection('receivedFriendRequests')
        .snapshots()
        .handleError((error) => print("Error retrieving friends requests: $error"))
        .map((snapshot) {
      print("Retrieving recieved friend requests: ${snapshot.docs.length}");
      receivedFriendRequests.assignAll(snapshot.docs.map((doc) => FriendModel.fromFirestore(doc)).toList());
    });
  }

  // Stream to get the sent friend requests and store them reactively
  Stream<void> listenToSentFriendRequests(String userId) {
    return userCollection.doc(userId).collection('sentFriendRequests').snapshots().map((snapshot) {
      print("Retrieving sent friend requests: $snapshot");

      sentFriendRequests.assignAll(snapshot.docs.map((doc) => FriendModel.fromFirestore(doc)).toList());
    });
  }*/




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


  Future<QuerySnapshot> searchByUserName(String username, {int limit = 10}) async {
    String searchKey = username.toLowerCase();
    return await userCollection
        .where("fullname", isGreaterThanOrEqualTo: searchKey)
        .where("fullname", isLessThanOrEqualTo: '$searchKey\uf8ff')// For prefix search
        .limit(limit)
        .get();
  }

  Future<bool> sendFriendRequest( FriendModel request) async {
    final userController = Get.find<UserController>();
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
        'fcmToken': userController.userData.value?.fcmToken,
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


  /*Stream<UserModel?> getUserById(String userId) {
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
  }*/

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


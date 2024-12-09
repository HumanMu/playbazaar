import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/enums.dart';
import 'package:playbazaar/functions/enum_converter.dart';
import '../models/DTO/recent_interacted_user_dto.dart';
import '../models/friend_model.dart';
import '../models/friend_request_result_action.dart';
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


  Stream<List<FriendModel>> listenToFriends(String userId) {
    return userCollection
        .doc(userId)
        .collection('friends')
        .where('friendshipStatus', isEqualTo: 'received')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<FriendRequestResultModel>> listenToFriendRequestsResult(String uid) {
    return userCollection
        .doc(uid)
        .collection('friendshipresult')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequestResultModel.fromFirestore(doc))
        .toList());
  }

  Future<bool> deleteFriendRequestResult(String uid, String friendId) async{
    try {
      await userCollection.doc(uid).collection('friendshipresult').doc(friendId).delete();
      return true;
    }catch(e){
      return false;
    }
  }


  Future<QuerySnapshot<Map<String, dynamic>>> getFriendList() {
    return userCollection.doc(userId).collection('friends').get();
  }


  Future<QuerySnapshot> searchByUserName(String username, {int limit = 10}) async {
    String searchKey = username.toLowerCase();
    return await userCollection
        .where("fullname", isGreaterThanOrEqualTo: searchKey)
        .where("fullname", isLessThanOrEqualTo: '$searchKey\uf8ff')// For prefix search
        .limit(limit)
        .get();
  }

  Future<List<FriendModel>> searchByFriendsName(String userId, String userFriendName) async {
    String searchKey = userFriendName.toLowerCase();
    final friendsSnapshot = await userCollection.doc(userId).collection(
        'friends')
        .where("fullname", isGreaterThanOrEqualTo: searchKey)
        .where("fullname", isLessThanOrEqualTo: '$searchKey\uf8ff') // For prefix search
        .limit(10)
        .get();


    if (friendsSnapshot.docs.isNotEmpty) {
      List<FriendModel> friends = friendsSnapshot.docs.map((doc) =>
          FriendModel.fromFirestore(doc)).toList();
      return friends;
    } else {
      return [];
    }
  }

  Future<bool> sendFriendRequest( FriendModel request) async {
    String currentUserId = firebaseAuth.currentUser!.uid;

    if(currentUserId == ""){
      if (kDebugMode) {
        print("Current user not found");
      }
      return false;
    }
    DocumentReference friendDocRef = userCollection.doc(request.uid).collection("friends").doc(currentUserId);
    DocumentReference userDocRef = userCollection.doc(currentUserId).collection("friends").doc(request.uid);
    try{
      await userDocRef.set(request.toMap());
      await friendDocRef.set({
        'senderId': currentUserId,
        'uid': currentUserId,
        'fullname': firebaseAuth.currentUser?.displayName?.toLowerCase() ??  "",
        'avatarImage': firebaseAuth.currentUser?.photoURL ?? "",
        'friendshipStatus': friendShipState2String(FriendshipStatus.received),
        'chatId': ''
      });

      
      return true;
    }catch(e){
      if (kDebugMode) {
        print("Sending friend request failed - service: $e");
      }
      return false;
    }
  }




  Future<RecentInteractedUserDto?> acceptFriendRequest(String chatId, String friendId) async {
    String uid = firebaseAuth.currentUser!.uid;
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference userDocRef =  userCollection.doc(uid).collection('friends').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('friends').doc(uid);
    DocumentReference friendshipResult =  userCollection.doc(friendId).collection('friendshipresult').doc(uid);

    try {
      final snapshots = await Future.wait([
        userDocRef.get(),
        friendDocRef.get(),
      ]);

      final userSnapshot = snapshots[0];
      final friendSnapshot = snapshots[1];

      if (!userSnapshot.exists || !friendSnapshot.exists) {
        return null;
      }

      // Prepare the updated data
      final Map<String, dynamic> userData = {
        ...userSnapshot.data() as Map<String, dynamic>,
        'chatId': chatId,
        'friendshipStatus': friendShipState2String(FriendshipStatus.good),
      };

      final Map<String, dynamic> friendData = {
        ...friendSnapshot.data() as Map<String, dynamic>,
        'chatId': chatId,
        'friendshipStatus': friendShipState2String(FriendshipStatus.good),
      };


      FriendRequestResultModel friendshipResultState = FriendRequestResultModel(
        uid: uid,
        friendshipStatus: FriendshipStatus.accepted,
        chatId: chatId,
      );

      batch.set(friendshipResult, friendshipResultState.toFirestore());
      batch.update(userDocRef, userData);
      batch.update(friendDocRef, friendData);

      await batch.commit();

      // Adding to the users device
      RecentInteractedUserDto recentUser = RecentInteractedUserDto(
        uid: userData['uid'],
        fullname: userData['fullname'],
        avatarImage: userData['avatarImage'],
        lastMessage: 'say_hi',
        timestamp: Timestamp.now(),
        friendshipStatus: 'good',
        chatId: chatId,
      );
      return recentUser;

    }catch(e) {
      print('Error accepting friend request - service');
      return null;
    }
  }

  Future<bool> cancelFriendshipRequest(String friendId) async {
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    String currentUserId = firebaseAuth.currentUser!.uid;
    DocumentReference friendDocRef = userCollection.doc(friendId).collection("friends").doc(currentUserId);
    DocumentReference userDocRef = userCollection.doc(currentUserId).collection("friends").doc(friendId);

    try{
      batch.delete(userDocRef);
      batch.delete(friendDocRef);
      await batch.commit();
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
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference userDocRef =  userCollection.doc(ui).collection('friends').doc(friendId);
    DocumentReference friendDocRef =  userCollection.doc(friendId).collection('friends').doc(ui);

      try{
        batch.delete(userDocRef);
        batch.delete(friendDocRef);
        await batch.commit();
        return true;

      }catch(e){
        if (kDebugMode) {
          print("Error declining friend request: $e");
        }
        return false;
      }
  }

  Future<bool> removeFriendById(String friendId) async {
    String uid = firebaseAuth.currentUser!.uid;
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      DocumentReference userDocRef = userCollection.doc(uid).collection('friends').doc(friendId);
      DocumentReference friendDocRef = userCollection.doc(friendId).collection('friends').doc(uid);
      DocumentReference friendshipResult =  userCollection.doc(friendId).collection('friendshipresult').doc(uid);


      DocumentSnapshot userDoc = await userDocRef.get();
      DocumentSnapshot friendDoc = await friendDocRef.get();

      String? chatId;
      if (userDoc.exists && userDoc.data() != null) {
        chatId = (userDoc.data() as Map<String, dynamic>)['chatId'];
      }

      if (chatId == null && friendDoc.exists && friendDoc.data() != null) {
        chatId = (friendDoc.data() as Map<String, dynamic>)['chatId'];
      }

      if (chatId != null) {
        await _privateMessageService.deletePrivateMessageCollection(chatId);
      }

      FriendRequestResultModel friendshipResultState = FriendRequestResultModel(
        uid: uid,
        friendshipStatus: FriendshipStatus.unfriended,
        chatId: chatId,
      );

      if (userDoc.exists && friendDoc.exists) {
        batch.delete(userDocRef);
        batch.delete(friendDocRef);
        batch.set(friendshipResult, friendshipResultState.toFirestore());
      }

      await batch.commit();
      return true;

    } catch (e) {
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


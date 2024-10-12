import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:playbazaar/functions/enum_converter.dart';
import '../../constants/constants.dart';
import '../../models/user_model.dart';
import '../repositories/user_repository.dart';

class FirestoreServices extends ChangeNotifier {
  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection
  = FirebaseFirestore.instance.collection("friends");

  final FirestoreRepository _repository = FirestoreRepository();
  late UserModel singleUser;
  final List<UserModel> userList = [];


  Future<bool> createUser(String fullname, String email, String userId) async {
    try {
      UserModel newUser = UserModel(
        uid: userId,
        fullname: fullname.toLowerCase(),
        email: email.toLowerCase(),
        coins: 0,
        userPoints: 0,
        aboutme: "",
        avatarImage: "",
        timestamp: Timestamp.now(),
        lastUpdated: Timestamp.now(),
        availabilityState: '',
        accountCondition: AccountCondition.good,
        role: UserRole.normal,
        groupsId: [],
      );

      // Use the toJson method to set data in Firestore
      await userCollection.doc(userId).set(newUser.toJson());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      return false;
    }
  }



  Future<bool> editUserData( UserProfileModel upm, String userId ) async {
    try {
      Map<String, dynamic> updateData = {};

      // Add fields to update only if they are provided (non-null)
      if (upm.fullname != null) updateData['fullname'] = upm.fullname;
      if (upm.aboutMe != null) updateData['aboutme'] = upm.aboutMe;

      // Check if there's something to update
      if (updateData.isNotEmpty) {
        await userCollection.doc(userId).update(updateData);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }




  saveFriend(String userId, String friendId, String collectionName) async {
    DocumentReference friendDocRef = userCollection.doc(friendId);
    DocumentSnapshot friendDoc = await friendDocRef.get();

    await userCollection.doc(userId).collection(collectionName)
        .doc(friendId).set({
      'uid': friendId,
      'fullname': friendDoc['fullname'],
      'email': friendDoc['email'],
      'avatarImage': friendDoc['avatarImage'],
      'timestamp': Timestamp.now(),
      'availabilityState': friendDoc['availabilityState'],
    });
  }


  Future<List<UserModel>> getUserByEmail(String? email) async {
    List<UserModel> userList = [];

    try {
      QuerySnapshot snapshot = await _repository.getUserData(email);
      if (snapshot.docs.isNotEmpty) {
        userList = snapshot.docs.map((doc) {

          UserRole ur = string2UserRole(doc['role']);
          AccountCondition ac = string2AccountCondition(doc['accountCondition']);

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
            accountCondition: ac,
            groupsId: doc['groupsId'] ?? [],
            role: ur,
          );
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user by email: $e");
      }
    }

    return userList;
  }



  Future getUserById(String id) async {
    QuerySnapshot snapshot = await _repository.getUserById(id);
    if (snapshot.docs.isNotEmpty) {
      singleUser = snapshot.docs.map((doc) {
        String roleString = doc['role'] ?? 'normal';
        UserRole role = UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == roleString,
          orElse: () => UserRole.normal,
        );

        String accountConditionString = doc['role'] ?? 'good';
        AccountCondition accountCondition = AccountCondition.values.firstWhere(
              (e) => e.toString().split('.').last == accountConditionString,
          orElse: () => AccountCondition.good,
        );

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
          groupsId: doc['groupsId'] ?? [],
          role: role,
        );
      }).single;
    } else {
      return;
    }
  }



}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../constants/enums.dart';
import '../../models/user_model.dart';
import 'package:playbazaar/models/DTO/user_profile_dto.dart';

class FirestoreServices extends ChangeNotifier {
  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection
  = FirebaseFirestore.instance.collection("friends");

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


}

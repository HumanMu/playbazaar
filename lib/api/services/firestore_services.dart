import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../constants/constants.dart';
import '../../models/user_model.dart';
import '../firestore/firestore_account.dart';
import '../repositories/user_repository.dart';

class FirestoreServices extends ChangeNotifier {
  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection
  = FirebaseFirestore.instance.collection("friends");

  final FirestoreRepository _repository = FirestoreRepository();
  late UserModel _singleUser;
  final List<UserModel> _userList = [];


  Future<void> saveUserData(
      String firstname,
      String lastname,
      String email,
      String userId,
      ) async {
    try {
      await userCollection.doc(userId).set({
        "uid": userId,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
        "userpoints": 0,
        "aboutme": "",
        "avatarImage": "",
        "timestamp": Timestamp.now(),
        "groups": [],
        "friendsId": [],
        "availabilityState": '',
        "accountState" : 'inaccessible',
        'role': UserRole.normal.toString().split('.').last,
      });
      await FirestoreAccount().deleteInaccessibleAccounts();

    } catch (e) {
      throw Exception("Failed to save user data: $e");
    }
  }



  saveFriend(String userId, String friendId, String collectionName) async {
    DocumentReference friendDocRef = userCollection.doc(friendId);
    DocumentSnapshot friendDoc = await friendDocRef.get();

    await userCollection.doc(userId).collection(collectionName)
        .doc(friendId).set({
      'uid': friendId,
      'firstname': friendDoc['firstname'],
      'email': friendDoc['email'],
      'lastname': friendDoc['lastname'],
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
          String roleString = doc['role'] ?? 'normal';
          UserRole role = UserRole.values.firstWhere(
                (e) => e.toString().split('.').last == roleString,
            orElse: () => UserRole.normal,
          );

          return UserModel(
            userId: doc['uid'],
            email: doc['email'],
            firstname: doc['firstname'],
            lastname: doc['lastname'],
            userPoints: doc['userpoints'],
            aboutme: doc['aboutme'],
            avatarImage: doc['avatarImage'],
            timestamp: doc['timestamp'],
            availabilityState: doc['availabilityState'],
            accountState: doc['accountState'],
            role: role,
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
      _singleUser = snapshot.docs.map((doc) {
        String roleString = doc['role'] ?? 'normal';
        UserRole role = UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == roleString,
          orElse: () => UserRole.normal,
        );

        return UserModel(
          userId: doc['uid'],
          email: doc['email'],
          firstname: doc['firstname'],
          lastname: doc['lastname'],
          userPoints: doc['userpoints'],
          aboutme: doc['aboutme'],
          avatarImage: doc['avatarImage'],
          timestamp: doc['timestamp'],
          availabilityState: doc['availabilityState'],
          accountState: doc['accountState'],
          role: role,
        );
      }).single;
    } else {
      return;
    }
  }



}


import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/constants.dart';


class UserModel {
  String userId;
  String firstname;
  String email;
  String? aboutme;
  String? lastname;
  int? userPoints;
  String? avatarImage;
  Timestamp? timestamp;
  String? availabilityState;
  String? accountState;
  UserRole role;



  UserModel({ 
    required this.userId,
    required this.firstname,
    required this.email,
    this.aboutme,
    this.lastname,
    this.userPoints,
    this.avatarImage,
    this.timestamp,
    this.availabilityState,
    this.accountState,
    this.role = UserRole.normal,
    
  });

  factory UserModel.fromJson(DocumentSnapshot snapshot) {
    String roleString = snapshot.get('role') as String? ?? 'normal';
    UserRole role = UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString,
      orElse: () => UserRole.normal,
    );

    return UserModel(
        userId: snapshot.get('uid') as String,
        firstname: snapshot.get('firstname') as String,
        lastname: snapshot.get('lastname') as String,
        email: snapshot.get('email') as String,
        userPoints: snapshot.get('userpoints') as int,
        aboutme: snapshot.get('aboutme') as String,
        avatarImage: snapshot.get('avatarImage') as String?,
        timestamp: snapshot.get('timestamp') as Timestamp?,
        availabilityState: snapshot.get('availabilityStatus') as String,
        accountState: snapshot.get('accountState') as String,
        role: role,
    );
  }

  toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'userpoints': userPoints,
      'aboutme': aboutme,
      'avatarImage': avatarImage,
      'timestamp': timestamp,
      'availabilityState': availabilityState,
      'accountState': accountState,
      'role': role.name,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final user = doc.data()!;
    return UserModel(
      userId: user['uid'],
      firstname: user['firstname'],
      lastname: user['lastname'],
      email: user['email'],
      userPoints: user['userpoints'],
      aboutme: user['aboutme'],
      avatarImage: user['avatarImage'],
      timestamp: user['timestamp'],
      availabilityState: user['availabilityState'],
      accountState: user['accountState'],
      role: UserRole.values.byName(user['role']) ?? UserRole.normal,
    );
  }
}

class UserFriendModel {
  String friendId;
  String firstname;
  String email;
  String lastname;
  String avatarImage;
  Timestamp? timestamp;
  String availabilityState;

  UserFriendModel({
    required this.friendId,
    required this.firstname,
    required this.email,
    required this.lastname,
    required this.avatarImage,
    required this.availabilityState,
    this.timestamp,
  });

  factory UserFriendModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc){
    final user = doc.data()!;
    return UserFriendModel(
      friendId: user['uid'],
      firstname: user['firstname'],
      lastname: user['lastname'],
      email: user['email'],
      avatarImage: user['avatarImage'],
      timestamp: Timestamp.now(),
      availabilityState: user['availabilityState'],

    );
  }
}

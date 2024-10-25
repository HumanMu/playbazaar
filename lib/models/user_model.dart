
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/constants.dart';
import '../functions/enum_converter.dart';


class UserModel {
  String uid;
  String fullname;
  String email;
  int coins;
  int userPoints;
  AccountCondition accountCondition;
  UserRole role;
  String? aboutme;
  String? avatarImage;
  Timestamp? timestamp;
  Timestamp? lastUpdated;
  String? availabilityState;
  List<String>? groupsId;
  String? fcmToken;

  UserModel({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.coins,
    required this.userPoints,
    this.lastUpdated,
    this.accountCondition = AccountCondition.good,
    this.role = UserRole.normal,
    this.aboutme,
    this.avatarImage,
    this.timestamp,
    this.availabilityState,
    this.groupsId,
    this.fcmToken
  });

  factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
    String roleString = snapshot.get('role') as String? ?? 'normal';
    String conditiontring = snapshot.get('accountCondition') as String? ?? 'good';


    return UserModel(
      uid: snapshot.get('uid') as String,
      fullname: snapshot.get('fullname') as String,
      email: snapshot.get('email') as String,
      coins: snapshot.get('coins') as int,
      userPoints: snapshot.get('userpoints') as int,
      aboutme: snapshot.get('aboutme') as String?,
      avatarImage: snapshot.get('avatarImage') as String?,
      timestamp: snapshot.get('timestamp') as Timestamp?,
      lastUpdated: snapshot.get('lastUpdated') as Timestamp?,
      availabilityState: snapshot.get('availabilityState') as String?,
      accountCondition: string2AccountCondition(conditiontring),
      groupsId: List<String>.from(snapshot.get('groupsId') ?? []),
      role: string2UserRole(roleString),
      fcmToken: snapshot.get('fcmToken')
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid' : uid,
      'fullname': fullname,
      'email': email,
      'coins' : coins,
      'userpoints': userPoints,
      'aboutme': aboutme,
      'avatarImage': avatarImage,
      'timestamp': timestamp,
      'lastUpdated': lastUpdated,
      'availabilityState': availabilityState,
      'accountCondition': accountCondition.name,
      'role': role.name,
      'groupsId': groupsId,
      'fcmToken': fcmToken
    };
  }
}


class UserProfileModel {
  final String email;
  final String? fullname;
  final String? aboutMe;
  final int? userPoint;

  UserProfileModel({
    required this.email,
    this.fullname,
    this.aboutMe,
    this.userPoint,
  });
}




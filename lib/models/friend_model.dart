import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/functions/enum_converter.dart';

import '../constants/constants.dart';

class FriendModel {
  String uid;
  String fullname;
  String avatarImage;
  String chatId;
  FriendshipStatus friendshipStatus;

  FriendModel({
    required this.uid,
    required this.fullname,
    required this.avatarImage,
    required this.chatId,
    required this.friendshipStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'avatarImage': avatarImage,
      'friendshipStatus': friendShipState2String(FriendshipStatus.good),
      'chatId': chatId,
    };
  }

  factory FriendModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc){
    final user = doc.data()!;
    FriendshipStatus friendStat = string2FriendshipState(doc['friendshipStatus']);
    return FriendModel(
      uid: user['uid'],
      fullname: user['fullname'],
      avatarImage: user['avatarImage'],
      friendshipStatus: friendStat,
      chatId: user['chatId'] ?? "",
    );
  }
}
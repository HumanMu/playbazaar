
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/functions/enum_converter.dart';

import '../constants/enums.dart';

class FriendRequestResultModel {
  final String uid;
  final FriendshipStatus friendshipStatus;
  final String? chatId;


  FriendRequestResultModel({
    required this.uid,
    required this.friendshipStatus,
    this.chatId
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'friendshipStatus': friendShipState2String(friendshipStatus),
      'chatId': chatId
    };
  }

  factory FriendRequestResultModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FriendRequestResultModel(
      uid: data['uid'] ?? '',
      friendshipStatus: string2FriendRequestResult(data['friendshipStatus']),
      chatId: data['chatId'],
    );
  }

}

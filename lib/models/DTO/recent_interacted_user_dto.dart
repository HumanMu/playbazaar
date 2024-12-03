

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/functions/enum_converter.dart';

import '../friend_model.dart';

class RecentInteractedUserDto {
  final String uid;
  final String fullname;
  final String? avatarImage;
  final String? lastMessage;
  final String friendshipStatus;
  final Timestamp timestamp;
  final String? chatId;

  RecentInteractedUserDto({
    required this.uid,
    required this.fullname,
    this.avatarImage,
    this.lastMessage,
    required this.friendshipStatus,
    required this.timestamp,
    this.chatId
  });
}

FriendModel recentFriend2FriendModel(RecentInteractedUserDto recentUser) {
  return FriendModel(
      senderId: recentUser.uid, // Adjust if needed
      uid: recentUser.uid,
      fullname: recentUser.fullname,
      avatarImage: recentUser.avatarImage ?? '',
      chatId: recentUser.chatId ?? '',
      friendshipStatus: string2FriendshipState(recentUser.friendshipStatus)
  );
}

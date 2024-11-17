

import 'package:cloud_firestore/cloud_firestore.dart';

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
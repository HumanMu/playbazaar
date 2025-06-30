
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationModel {
  final String? fcmToken;
  final bool isActive; // The specifikke enhed
  final String deviceId;
  final bool fcmFriendRequest;
  final bool fcmNewMessages;
  final bool fcmPlayBazaar;
  final Timestamp? lastUpdate;

  PushNotificationModel({
    this.fcmToken,
    required this.isActive,
    required this.deviceId,
    required this.fcmFriendRequest,
    required this.fcmNewMessages,
    required this.fcmPlayBazaar,
    this.lastUpdate,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fcmToken': fcmToken,
      'isActive' : isActive,
      'deviceId': deviceId,
      'fcmFriendRequest': fcmFriendRequest,
      'fcmNewMessages' : fcmNewMessages,
      'fcmPlayBazaar' : fcmPlayBazaar,
      'lastUpdate': lastUpdate,
    };
  }

  factory PushNotificationModel.fromFirestore(Map<String, dynamic> map) {
    return PushNotificationModel(
      fcmToken: map['fcmToken'] as String?,
      isActive: map['isActive'] as bool,
      deviceId: map['deviceId'] as String,
      fcmFriendRequest: map['fcmFriendRequest'] as bool,
      fcmNewMessages: map['fcmNewMessages'] as bool,
      fcmPlayBazaar: map['fcmPlayBazaar'] as bool,
      lastUpdate: map['lastUpdate'] as Timestamp,
    );
  }
}

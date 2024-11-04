
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationModel {
  String? fcmToken;
  String deviceId;
  bool fcmFriendRequest;
  bool fcmNewMessages;
  bool fcmPlayBazaar;
  Timestamp? lastUpdate;

  PushNotificationModel({
    this.fcmToken,
    required this.deviceId,
    required this.fcmFriendRequest,
    required this.fcmNewMessages,
    required this.fcmPlayBazaar,
    this.lastUpdate,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fcmToken': fcmToken,
      'deviceId': deviceId,
      'fcmFriendRequest': fcmFriendRequest,
      'fcmNewMessages' : fcmNewMessages,
      'fcmPlayBazaar' : fcmPlayBazaar,
      'lastLoginTime': lastUpdate,
    };
  }

  factory PushNotificationModel.fromFirestore(Map<String, dynamic> map) {
    return PushNotificationModel(
      fcmToken: map['fcmToken'] as String?,
      deviceId: map['deviceId'] as String,
      fcmFriendRequest: map['fcmFriendRequest'] as bool,
      fcmNewMessages: map['fcmNewMessages'] as bool,
      fcmPlayBazaar: map['fcmPlayBazaar'] as bool,
      lastUpdate: map['lastUpdate'] as Timestamp,
    );
  }
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationHelper{
  static const AndroidNotificationChannel friendRequestChannel = AndroidNotificationChannel(
    'friend_request',
    'Friend Requests',
    description: 'Channel for friend request notifications',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
    'message',
    'Messages',
    description: 'Channel for message notifications',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationDetails friendRequestDetails = AndroidNotificationDetails(
    'friend_request',
    'Friend Requests',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const AndroidNotificationDetails messageDetails = AndroidNotificationDetails(
    'message',
    'Messages',
    importance: Importance.high,
    priority: Priority.high,
  );
}

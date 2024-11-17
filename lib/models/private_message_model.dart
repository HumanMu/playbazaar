import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateMessage {
  String senderId;
  String sendersAvatar;
  String recipientId;
  String senderName;
  String text;
  Timestamp timestamp;

  PrivateMessage({
    required this.senderId,
    required this.sendersAvatar,
    required this.recipientId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  // Convert a MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'sendersAvatar': sendersAvatar,
      'recipientId': recipientId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
    };
  }

  // Factory method to create a MessageModel from Firestore DocumentSnapshot
  factory PrivateMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrivateMessage(
      senderId: data['senderId'] ?? '',
      sendersAvatar: data['sendersAvatar'] ?? '',
      recipientId: data['recipientId'],
      senderName: data['senderName'],
      text: data['text'],
      timestamp: (data['timestamp']),
    );
  }
}

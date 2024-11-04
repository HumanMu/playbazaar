import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateMessage {
  String senderId;
  String recipientId;
  String senderName;
  String text;
  DateTime timestamp;

  PrivateMessage({
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  // Convert a MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
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
      recipientId: data['recipientId'],
      senderName: data['senderName'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

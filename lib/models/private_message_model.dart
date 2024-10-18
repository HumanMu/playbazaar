import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateMessage {
  String messageId;
  String senderId;
  String senderName;
  String text;
  DateTime timestamp;

  PrivateMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  // Convert a MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
    };
  }

  // Factory method to create a MessageModel from Firestore DocumentSnapshot
  factory PrivateMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrivateMessage(
      messageId: doc.id,
      senderId: data['senderId'],
      senderName: data['senderName'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

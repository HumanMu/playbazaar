

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp timestamp;
  final bool isSentByMe;

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });

  // Convert Message object to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
      'isSentByMe': isSentByMe,
    };
  }

  // Create a Message object from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderName: map['senderName'],
      text: map['text'],
      timestamp: map['timestamp'],
      isSentByMe: map['isSentByMe'],
    );
  }
}

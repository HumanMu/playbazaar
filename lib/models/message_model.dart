

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final bool isSentByMe;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
  });

  // Convert Message object to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'isSentByMe': isSentByMe,
      'timestamp' : timestamp,
    };
  }

  // Create a Message object from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderName: map['senderName'],
      text: map['text'],
      isSentByMe: map['isSentByMe'],
      timestamp : map['timestamp']
    );
  }
}

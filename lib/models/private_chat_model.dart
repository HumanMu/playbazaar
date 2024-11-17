import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChatModel {
  List<String> userIds;
  String lastMessage;
  DateTime lastMessageTime;
  List<String> readBy; // Users who have read the last message


  PrivateChatModel({
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'readBy': readBy,
    };
  }

  // Factory method to create a ChatModel from Firestore DocumentSnapshot
  factory PrivateChatModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrivateChatModel(
      userIds: List<String>.from(data['userIds']),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      readBy: List<String>.from(data['readBy']),

    );
  }
}

class PrivateMessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  PrivateMessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  // Factory method to create a ChatModel from Firestore DocumentSnapshot
  factory PrivateMessageModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrivateMessageModel(
      messageId: data['messageId'],
      chatId: data['chatId'],
      senderId: data['senderId'],
      content: data['content'],
      timestamp:(data['timestamp'] as Timestamp).toDate()
    );
  }
}




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




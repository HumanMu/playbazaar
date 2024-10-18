import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/private_chat_model.dart';
import '../models/private_message_model.dart';

class PrivateMessageService extends GetxService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('privateMessages');


  Future<String?> createChat(String currentUserId, String friendId) async {
    PrivateChatModel chat = PrivateChatModel(
      userIds: [currentUserId, friendId],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      readBy: [],
    );

    try {
      DocumentReference docRef = await chatCollection.add(chat.toMap());
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating chat: $e");
      }
      return null;
    }
  }


  Future<void> sendMessage(String chatId, PrivateMessage message) async {
    await chatCollection.doc(chatId)
        .collection('messages').doc().set(message.toMap());

    /*await chatCollection.doc(chatId).update({  // This works - deaktivated for cost efficiency
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
    });*/
  }


  Stream<List<PrivateMessage>> getMessages(String chatId) {
    return chatCollection.doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PrivateMessage.fromFirestore(doc)).toList();
    });
  }
}

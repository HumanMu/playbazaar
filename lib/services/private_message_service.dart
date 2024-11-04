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


  Future<bool> deletePrivateMessageCollection(String collectionId) async {
    DocumentReference docRef = chatCollection.doc(collectionId);
    CollectionReference messagesRef = docRef.collection('messages');

    try {
      // First try with a small batch to minimize reads if collection is small
      WriteBatch batch = FirebaseFirestore.instance.batch();
      QuerySnapshot snapshot = await messagesRef.limit(50).get();

      // If we got less than 50 documents, we know we got all of them
      // If we got exactly 50, there might be more
      bool mightHaveMore = snapshot.docs.length == 50;

      while (true) {
        // Add current batch of documents to delete
        for (final DocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        // If we don't think there are more documents, or we didn't get any documents
        // this time, break the loop
        if (!mightHaveMore || snapshot.docs.isEmpty) {
          break;
        }

        // If we got here, we need to commit this batch and get more documents
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();

        // Get next batch of documents
        snapshot = await messagesRef.limit(500).get();
        mightHaveMore = snapshot.docs.length == 500;
      }

      // Commit any remaining deletes
      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
      await docRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

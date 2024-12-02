import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/private_message_model.dart';

class PrivateMessageService extends GetxService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('privateMessages');

  Future<String?> createChat(String currentUserId, String friendId) async {

    try {
      DocumentReference docRef = await chatCollection.add({
        'userIds': [currentUserId, friendId],
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
        'readBy': [],
      });
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating chat: $e");
      }
      return null;
    }
  }


  Future<void> sendMessage(String chatId, PrivateMessage message) async   {
    await chatCollection.doc(chatId)
        .collection('messages')
        .doc()
        .set({
      ...message.toFirestore(),
      'ttl_timestamp': Timestamp.fromDate(
        DateTime.now().add(Duration(days: 7)) // Longer TTL reduces frequency
      )
    });
        //.collection('messages').doc().set(message.toFirestore());

    await chatCollection.doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
      'senderId': message.senderId,
      'sendersAvatar': message.sendersAvatar,
      'senderName': message.senderName,
    });
  }


  Stream<List<PrivateMessage>> getMessages(String chatId, {int pageSize = 10}) {
    return chatCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PrivateMessage.fromFirestore(doc))
        .toList());
  }

  Future<List<PrivateMessage>> loadMoreMessages(String chatId, DocumentSnapshot lastDocument, {int pageSize = 10}) {
    return chatCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get()
        .then((snapshot) => snapshot.docs
        .map((doc) => PrivateMessage.fromFirestore(doc))
        .toList());
  }


  Future<bool> deletePrivateMessageCollection(String collectionId) async {
    if (collectionId.isEmpty) {
      print("Invalid collection ID provided");
      return false;
    }

    final DocumentReference docRef = chatCollection.doc(collectionId);
    final CollectionReference messagesRef = docRef.collection('messages');

    try {
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print("Chat document doesn't exist: $collectionId");
      }

      // Get total count of messages for logging
      final QuerySnapshot countSnapshot = await messagesRef.get();
      final int totalMessages = countSnapshot.size;

      if (totalMessages == 0) {
        await docRef.delete();
        return true;
      }

      // Delete messages in smaller batches
      const int batchSize = 50;
      int deletedCount = 0;

      while (true) {
        final QuerySnapshot batch = await messagesRef.limit(batchSize).get();

        if (batch.docs.isEmpty) {
          break;
        }

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();
        for (final doc in batch.docs) {
          writeBatch.delete(doc.reference);
        }

        await writeBatch.commit();
        deletedCount += batch.docs.length;

        // Small delay to prevent overloading
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Final verification
      final verificationSnapshot = await messagesRef.limit(1).get();
      if (verificationSnapshot.docs.isEmpty) {
        await docRef.delete();
        print("Successfully deleted all messages and chat document");
        return true;
      } else {
        print("Warning: Some messages may remain");
        return false;
      }

    } catch (e) {
      print("Error in deletePrivateMessageCollection: $e");
      return false;
    }
  }
}

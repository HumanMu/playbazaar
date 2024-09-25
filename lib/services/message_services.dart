import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

class MessageService {
  final String? userId;
  MessageService({this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");

  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromMap(doc.data()))
        .toList());
  }


  Future<void> sendMessageToGroup(String groupId, Message message) async {
    try {
      await groupCollection.doc(groupId).collection('messages').add(message.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }
}
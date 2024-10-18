import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/group_message.dart';

class MessageService {
  final String? userId;
  MessageService({this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");

  Stream<List<GroupMessage>> getMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GroupMessage.fromMap(doc.data()))
        .toList());
  }


  Future<void> sendMessageToGroup(String groupId, GroupMessage message) async {
    try {
      await groupCollection.doc(groupId).collection('messages').add(message.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

}
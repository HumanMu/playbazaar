import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/group_message.dart';

class MessageService {
  final String? userId;
  MessageService({this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");

  Stream<List<GroupMessage>> listenToGroupChat(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GroupMessage.fromMap(doc.data()))
        .toList());
  }


  Future<void> sendMessageToGroup(String groupId, GroupMessage message) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('messages')
          .add({
        ...message.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
            DateTime.now().add(Duration(hours: 1))
        )
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/group_message.dart';

class MessageService extends GetxService {
  final String? userId;
  MessageService({this.userId});

  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection('groups');


  Stream<List<GroupMessage>> listenToGroupChat(String chatId, {int pageSize = 5}) {
    return groupCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GroupMessage.fromFirestore(doc.data(), doc.id))
        .toList()
        .reversed
        .toList());
  }


  Future<void> sendMessageToGroup(String groupId, GroupMessage message) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

}
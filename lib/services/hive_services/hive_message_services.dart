import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

import '../../models/DTO/hive_message_dto.dart';
import '../../models/hive_models/hive_message_model.dart';

class HiveMessageService extends GetxService {
  static const String boxName = 'recentMessages';
  static const int defaultMessageLimit = 25; // Default limit between 20-30
  late Box<HiveMessageModel> box;

  Future<void> init() async {
    box = await Hive.openBox<HiveMessageModel>(boxName);
  }


  Future<void> addMessage(HiveMessageDto dto) async {
    final message = HiveMessageModel(
      id: dto.id,
      content: dto.content,
      senderId: dto.senderId,
      receiverId: dto.receiverId,
      timestamp: dto.timestamp,
      isRead: dto.isRead,
    );
    await box.put(dto.id, message);

    // Clean up old messages for this conversation immediately
    await _cleanupOldMessages(dto.senderId, dto.receiverId);
  }

  List<HiveMessageDto> getRecentMessages(String user1Id, String user2Id) {
    final messages = box.values
        .where((msg) =>
    (msg.senderId == user1Id && msg.receiverId == user2Id) ||
        (msg.senderId == user2Id && msg.receiverId == user1Id))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return messages.take(defaultMessageLimit).map((msg) => msg.toDto()).toList();
  }

  // Clean up old messages keeping only the last 25 messages per conversation
  Future<void> _cleanupOldMessages(String user1Id, String user2Id) async {
    final conversationMessages = box.values
        .where((msg) =>
    (msg.senderId == user1Id && msg.receiverId == user2Id) ||
        (msg.senderId == user2Id && msg.receiverId == user1Id))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (conversationMessages.length > defaultMessageLimit) {
      final messagesToDelete = conversationMessages.sublist(defaultMessageLimit);
      for (var message in messagesToDelete) {
        await box.delete(message.id);
      }
    }
  }

  // Get the last message for a conversation
  HiveMessageDto? getLastMessage(String user1Id, String user2Id) {
    final messages = box.values
        .where((msg) =>
    (msg.senderId == user1Id && msg.receiverId == user2Id) ||
        (msg.senderId == user2Id && msg.receiverId == user1Id))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return messages.isNotEmpty ? messages.first.toDto() : null;
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final message = box.get(messageId);
    if (message != null) {
      final updatedMessage = HiveMessageModel(
        id: message.id,
        content: message.content,
        senderId: message.senderId,
        receiverId: message.receiverId,
        timestamp: message.timestamp,
        isRead: true,
      );
      await box.put(messageId, updatedMessage);
    }
  }

  // Mark all messages in a conversation as read
  Future<void> markConversationAsRead(String currentUserId, String otherUserId) async {
    final messages = box.values.where((msg) =>
    msg.receiverId == currentUserId &&
        msg.senderId == otherUserId &&
        !msg.isRead);

    for (var message in messages) {
      await markMessageAsRead(message.id);
    }
  }

  // Get unread messages count for a specific conversation
  int getUnreadCount(String currentUserId, String otherUserId) {
    return box.values
        .where((msg) =>
    msg.receiverId == currentUserId &&
        msg.senderId == otherUserId &&
        !msg.isRead)
        .length;
  }

  // Delete all messages in a conversation
  Future<void> deleteConversation(String user1Id, String user2Id) async {
    final conversationMessages = box.values.where((msg) =>
    (msg.senderId == user1Id && msg.receiverId == user2Id) ||
        (msg.senderId == user2Id && msg.receiverId == user1Id));

    for (var message in conversationMessages) {
      await box.delete(message.id);
    }
  }

  // Clear all messages
  Future<void> clearAllMessages() async {
    await box.clear();
  }
}
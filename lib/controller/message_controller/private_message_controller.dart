import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/recent_interacted_user_dto.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import '../../models/private_message_model.dart';
import '../../services/private_message_service.dart';
import '../../utils/show_custom_snackbar.dart';

class PrivateMessageController extends GetxController {
  final PrivateMessageService chatService = Get.put(PrivateMessageService());
  final HiveUserService _recentUsersService = Get.find();

  RxList<PrivateMessage> messages = <PrivateMessage>[].obs;
  RxList<RecentInteractedUserDto>? recentInteractedUserList;
  RxBool isLoading = true.obs;
  RxBool hasMoreMessages  = true.obs;
  DocumentSnapshot? lastDocument;
  StreamSubscription? _messagesSubscription;
  RxBool hasReachedEnd = false.obs;



  @override
  void onInit() {
    super.onInit();
    recentInteractedUserList = _recentUsersService.getRecentUsers().obs;
  }

  Future<void> sendMessage(String chatId, PrivateMessage pvm, RecentInteractedUserDto userDto) async {
    try {
      await chatService.sendMessage(chatId, pvm);
      await _recentUsersService.addOrUpdateRecentUser(userDto);
    }catch(e) {
      print("Error sending message: $e");
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }


  Future<String?> createChat(String currentUserId, String friendId) async {
    return await chatService.createChat(currentUserId, friendId);
  }

  void loadMessages(String chatId) {
    isLoading.value = true;
    _messagesSubscription = chatService.getMessages(chatId).listen((messageList) {
      if (messageList.isNotEmpty) {
        messages.value = messageList;
        lastDocument = messageList.last.documentSnapshot;
      }
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading messages: $error');
      isLoading.value = false;
    });
  }

  Future<void> loadMoreMessages(String chatId) async {
    if (isLoading.value || !hasMoreMessages.value || lastDocument == null) return;

    isLoading.value = true;
    try {
      final moreMessages = await chatService.loadMoreMessages(chatId, lastDocument!);

      if (moreMessages.isEmpty) {
        hasMoreMessages.value = false;
        hasReachedEnd.value = true;
      } else {
        // Ensure no duplicates when prepending
        final Set<String> existingMessageIds = messages.map((m) => m.documentSnapshot!.id).toSet();
        final filteredMoreMessages = moreMessages.where((m) => !existingMessageIds.contains(m.documentSnapshot!.id)).toList();

        messages.addAll(filteredMoreMessages);
        lastDocument = filteredMoreMessages.last.documentSnapshot;
      }
    } catch (e) {
      print('Error loading more messages: $e');
      hasMoreMessages.value = false;
      hasReachedEnd.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
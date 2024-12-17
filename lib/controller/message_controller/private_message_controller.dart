import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/message_list_dto.dart';
import 'package:playbazaar/models/DTO/recent_interacted_user_dto.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import '../../models/private_message_model.dart';
import '../../services/private_message_service.dart';
import '../../global_widgets/show_custom_snackbar.dart';

class PrivateMessageController extends GetxController {
  final PrivateMessageService chatService = Get.put(PrivateMessageService());
  final HiveUserService _recentUsersService = Get.find();
  RxList<RecentInteractedUserDto>? recentInteractedUserList;

  RxList<PrivateMessage> messages = <PrivateMessage>[].obs;
  RxList<MessageListDto> messageList = <MessageListDto>[].obs;
  RxBool isLoading = true.obs;
  RxBool hasMoreMessages  = true.obs;
  DocumentSnapshot? lastDocument;
  StreamSubscription? messagesSubscription;
  RxBool hasReachedEnd = false.obs;
  late final RxnString currentChatId = RxnString(null);



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
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }


  Future<String?> createChat(String currentUserId, String friendId) async {
    return await chatService.createChat(currentUserId, friendId);
  }


  /*void listenToNewMessages(String chatId) {
    isLoading.value = true;
    if(currentChatId.value != chatId){
      messagesSubscription!.cancel();
      currentChatId.value = chatId;
    }
    messagesSubscription = chatService.listenToPrivateMessages(chatId).listen((newMessageList) {
      if (newMessageList.isNotEmpty) {
        bool existUser = messageList.any((message) => message.userId == chatId);
        print("Exist user: $existUser");
      }
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
    });
  }*/


  void loadMessages(String chatId) {
    isLoading.value = true;
    chatService.listenToPrivateMessages(chatId).listen((newMessageList) {
      if (newMessageList.isNotEmpty) {
        messages.addAll(
            newMessageList.where((newMessage) =>
            !messages.any((existingMessage) =>
              existingMessage.documentSnapshot?.id == newMessage.documentSnapshot?.id)
            )
        );
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        lastDocument = messages.last.documentSnapshot;
      }
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading messages');
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
      hasMoreMessages.value = false;
      hasReachedEnd.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
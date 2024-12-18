import 'dart:async';

import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/group_dto/group_message_list_dto.dart';
import 'package:playbazaar/services/group_message_services.dart';
import '../../models/group_message.dart';
import '../../global_widgets/show_custom_snackbar.dart';

class GroupMessageController extends GetxController {
  final String? groupId;
  GroupMessageController({this.groupId});
  final MessageService _messageService = Get.put(MessageService());
  RxList<GroupMessage> messages = <GroupMessage>[].obs;
  RxList<GroupMessageListDto> messageList = <GroupMessageListDto>[].obs;
  StreamSubscription? _messageSubscription;


  @override
  void onClose(){
    _messageSubscription?.cancel();
    super.onClose();
  }


  void listenToMessages(String chatId) {
    _messageSubscription?.cancel();

    // Listen to the latest 5 messages initially
    _messageSubscription = _messageService
        .listenToGroupChat(chatId, pageSize: 5)
        .listen((initialMessages) {

      for (var message in initialMessages) {
        if (!messages.any((existingMessage) =>
        existingMessage.messageId == message.messageId)) {
          messages.add(message);
        }
      }
    });
  }



  Future<void> sendMessageToGroup(String chatId, GroupMessage message) async {
    try {
      _messageService.sendMessageToGroup(chatId, message);
    }catch(e) {
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }
}
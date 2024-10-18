import 'package:get/get.dart';
import '../../models/private_message_model.dart';
import '../../services/private_message_service.dart';
import '../../utils/show_custom_snackbar.dart';

class PrivateMessageController extends GetxController {
  final PrivateMessageService chatService = Get.find<PrivateMessageService>();

  RxList<PrivateMessage> messages = <PrivateMessage>[].obs;
  RxBool isLoading = true.obs;




  Future<String?> createChat(String currentUserId, String friendId) async {
    return await chatService.createChat(currentUserId, friendId);
  }

  Future<void> sendMessage(String chatId, PrivateMessage message) async {
    try {
      await chatService.sendMessage(chatId, message);
    }catch(e) {
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }


  void loadMessages(String chatId) {
    isLoading.value = true;
    chatService.getMessages(chatId).listen((messageList) {
      messages.value = messageList;
      isLoading.value = false;
    });
  }
}
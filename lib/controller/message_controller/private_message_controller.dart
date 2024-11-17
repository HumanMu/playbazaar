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

  void loadMessages(String chatId) {
    isLoading.value = true;
    chatService.getMessages(chatId).listen((messageList) {
      messages.value = messageList;
      isLoading.value = false;
    });
  }
}
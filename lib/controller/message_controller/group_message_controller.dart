import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:playbazaar/services/group_message_services.dart';
import '../../models/group_message.dart';
import '../../global_widgets/show_custom_snackbar.dart';

class GroupMessageController extends GetxController {
  final CollectionReference colRef = FirebaseFirestore.instance.collection('groups');
  final String groupId;
  final MessageService _messageService = MessageService();
  var messages = <GroupMessage>[].obs;

  GroupMessageController({required this.groupId});

  @override
  void onInit() {
    super.onInit();
    listenToMessages(groupId);
  }


  void listenToMessages(String groupId) {
    _messageService.getMessages(groupId).listen((messageList) {
      messages.value = messageList;
    });
  }

  Future<void> sendMessageToGroup( GroupMessage message) async {
    try {
      await MessageService().sendMessageToGroup(groupId, message);
    }catch(e) {
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }
}
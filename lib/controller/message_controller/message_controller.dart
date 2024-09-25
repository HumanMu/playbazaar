import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:playbazaar/services/message_services.dart';
import '../../models/message_model.dart';
import '../../utils/show_custom_snackbar.dart';

class MessageController extends GetxController {
  final CollectionReference colRef = FirebaseFirestore.instance.collection('groups');
  final String groupId;
  final MessageService _messageService = MessageService();
  var messages = <Message>[].obs;

  MessageController({required this.groupId});

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

  Future<void> sendMessageToGroup( Message message) async {
    try {
      await MessageService().sendMessageToGroup(groupId, message);
    }catch(e) {
      showCustomSnackbar("error_while_sending_message".tr, false);
    }
  }
}
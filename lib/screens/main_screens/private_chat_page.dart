import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/message_controller/private_message_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/models/DTO/recent_interacted_user_dto.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../admob/banner_ad.dart';
import '../../models/private_message_model.dart';
import '../widgets/cards/message_tile.dart';
import 'package:playbazaar/services/push_notification_service/push_notification_service.dart';

class PrivateChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String userName;
  final String recieverId;


  const PrivateChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.userName,
    required this.recieverId,

  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  late PrivateMessageController controller;
  late ScrollController _scrollController;
  String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? "";
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  String admin = "";


  @override
  void initState() {
    super.initState();
    Get.create(() => PrivateMessageController());
    controller = Get.find<PrivateMessageController>();
    _scrollController = ScrollController();
    controller.loadMessages(widget.chatId);
    ever(controller.messages, (_) => scrollToBottom());
    NotificationService().activeChatWithUser(widget.recieverId);
  }

  @override
  void dispose() {
    messageBox.dispose();
    Get.delete<PrivateMessageController>();
    NotificationService().endChat();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(capitalizeFullname(widget.chatName),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              color: Colors.teal[900],
              width: MediaQuery.of(context).size.width,
              child: BannerAdWidget(),  // The BannerAd widget
            ),
            Expanded(
              child: chatMessage(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: messageBox,
                        style: const TextStyle(
                            color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "your_message_here".tr,
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        sendPrivateMessage();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],)
    );
  }

  Widget chatMessage() {
    controller.loadMessages(widget.chatId);
    return Obx(() {
      if (controller.messages.isEmpty) {
        return const Center(
          child: Text(''),
        );
      }
      return ListView.builder(
        itemCount: controller.messages.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return MessageTile(
            message: message.text,
            sender: message.senderName,
            sendByMe: message.recipientId == currentUserId? true: false,
          );
        },
      );
    }
    );
  }



  sendPrivateMessage() {
      if(isMessageLengthAllowed()){
        PrivateMessage newMessage = PrivateMessage(
            senderId: currentUserId!,
            sendersAvatar: '',
            recipientId: widget.recieverId,
            senderName: splitBySpace(currentUserName)[0],
            text: messageBox.text,
            timestamp: Timestamp.now(),
        );

        RecentInteractedUserDto recentUser = RecentInteractedUserDto(
            uid: widget.recieverId,
            fullname: widget.chatName,
            avatarImage: '',
            lastMessage: messageBox.text,
            timestamp: Timestamp.now(),
            friendshipStatus: '',
            chatId: widget.chatId,
        );

        PrivateMessageController().sendMessage(widget.chatId, newMessage, recentUser);
        setState(() {
          messageBox.text = "";
        });
      }
    else{
      showCustomSnackbar("unexpected_result".tr, false);
    }

  }


  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  bool isMessageLengthAllowed() {
    final messageLength = messageBox.text.length;
    if (messageLength > 1000) {
      showCustomSnackbar(
          "${"current_message_length".tr}: $messageLength "
              "${"allowed_message_length_1000".tr}", false, timing: 6
      );
      return false;
    }

    if(messageBox.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

}
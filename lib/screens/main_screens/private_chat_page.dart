import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/message_controller/private_message_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/models/DTO/recent_interacted_user_dto.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../admob/adaptive_banner_ad.dart';
import '../../models/private_message_model.dart';
import '../widgets/tiles/message_tile_private.dart';
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
  final ScrollController _scrollController = ScrollController();
  final UserController userController = Get.find<UserController>();
  String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? "";
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  String admin = "";


  @override
  void initState() {
    super.initState();
    Get.create(() => PrivateMessageController());
    controller = Get.find<PrivateMessageController>();
    controller.loadMessages(widget.chatId);
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
              //margin: EdgeInsets.all(3),
              color: Colors.teal[900],
              width: MediaQuery.of(context).size.width,
              child: AdaptiveBannerAd(
                onAdLoaded: (isLoaded) {
                  if (isLoaded) {
                    debugPrint('Ad loaded in Quiz Screen');
                  } else {
                    debugPrint('Ad failed to load in Quiz Screen');
                  }
                },
              ),  // The BannerAd widget
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
    return Obx(() {
      if (controller.messages.isEmpty) {
        return Center(child: Text("auto_destractor_message".tr));
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          messageScrollListener(widget.chatId);
          return false;
        },
        child:Container(
          constraints: BoxConstraints(
          maxWidth: 600, // Max width of chat area
          ),
          color: Colors.white,
          child:  Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.messages.length +
                      (controller.isLoading.value ? 1 : 0) +
                      (controller.hasReachedEnd.value ? 1 : 0),
                  reverse: true,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value && index == 0) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Adjust index if loading indicator is present
                    int adjustedIndex = controller.isLoading.value
                        ? index - 1
                        : index;

                    if (controller.hasReachedEnd.value && adjustedIndex == controller.messages.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("reached_start_of_conversation".tr,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final message = controller.messages[adjustedIndex];
                    return MessageTilePrivate(
                      message: message.text,
                      sender: message.senderName,
                      sendByMe: message.recipientId == currentUserId,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  void messageScrollListener(String chatId) {
    if(controller.isLoading.value || !controller.hasMoreMessages.value){
      return;
    }
    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      controller.loadMoreMessages(chatId);
    }
  }

  void scrollToBottom() {
    Future.delayed(Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0); // Since the list is reversed
      }
    });
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
        userController.searchedFriends.removeWhere(
                (friend) => friend.uid == widget.recieverId);

        PrivateMessageController().sendMessage(widget.chatId, newMessage, recentUser);
        setState(() {
          messageBox.text = "";
        });
        scrollToBottom(); // Scroll to the bottom of the chat messages
      }
    else{
      showCustomSnackbar("unexpected_result".tr, false);
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
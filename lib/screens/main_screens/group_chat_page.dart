import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/message_controller/group_message_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../admob/banner_ad.dart';
import '../../models/group_message.dart';
import '../widgets/cards/message_tile.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String userName;


  const GroupChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.userName,

  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late GroupMessageController _messageController;
  late ScrollController _scrollController;
  String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? "";
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  String admin = "";


  @override
  void initState() {
    super.initState();
    Get.create(() => GroupMessageController(groupId: widget.chatId));
    _messageController = Get.find<GroupMessageController>();
    _scrollController = ScrollController();

    _messageController.listenToMessages(widget.chatId);
    ever(_messageController.messages, (_) => scrollToBottom());
  }

  @override
  void dispose() {
    messageBox.dispose();
    Get.delete<GroupMessageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(capitalizeFirstLetter(widget.chatName),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/chatinfo', arguments: {
                'chatId': widget.chatId,
                'chatName': widget.chatName,
                'adminName': admin,
              });
            },
            icon: const Icon(Icons.info, color: Colors.white70),
          )
        ],
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
                        sendGroupMessage();
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
    _messageController.listenToMessages(widget.chatId);
    return Obx(() {
      if (_messageController.messages.isEmpty) {
        return const Center(
          child: Text(''),
        );
      }
      return ListView.builder(
        itemCount: _messageController.messages.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final message = _messageController.messages[index];
          return MessageTile(
            message: message.text,
            sender: message.senderName,
            sendByMe: message.senderId == currentUserId? true: false,
          );
        },
      );
    }
    );
  }


  sendGroupMessage() {
    if(isMessageLengthAllowed()){
      GroupMessage message = GroupMessage(
        senderId: currentUserId!,
        senderName: splitBySpace(currentUserName)[0],
        text: messageBox.text,
        isSentByMe: true,
        timestamp: Timestamp.now(),
      );
      GroupMessageController(groupId: widget.chatId).sendMessageToGroup( message );
      setState(() {
        messageBox.clear();
      });
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
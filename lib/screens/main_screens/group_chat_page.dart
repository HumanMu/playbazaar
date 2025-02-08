import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/message_controller/group_message_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../admob/adaptive_banner_ad.dart';
import '../../models/group_message.dart';
import '../widgets/tiles/message_tile_group.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String userName;
  final bool isPublic;


  const GroupChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.userName,
    required this.isPublic
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late GroupMessageController _messageController;
  late ScrollController _scrollController;
  final FocusNode _messageFocusNode = FocusNode();
  String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? "";
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  String admin = "";


  @override
  void initState() {
    super.initState();

    Get.create(() => GroupMessageController());
    _messageController = Get.find<GroupMessageController>();
    _messageController.listenToMessages(widget.chatId);
    _scrollController = ScrollController();

    /*_messageController.listenToMessages();
    ever(_messageController.messages, (_) => scrollToBottom());*/
    _messageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
    _messageFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    messageBox.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _messageController.dispose();
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
                'isPublic': widget.isPublic,
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
          Container( // banner ad
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
            child: showMessages(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageBox,
                      focusNode: _messageFocusNode,
                      maxLines: null, // Allow multiple lines
                      keyboardType: TextInputType.multiline, // Enable multiline input
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "your_message_here".tr,
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        // Add border to make it more flexible
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white24,
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

  Widget showMessages() {
    return Obx(() {
      if (_messageController.messages.isEmpty) {
        return Center(
          child: Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.blueGrey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      }
      return Container(
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blueGrey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: _messageController.messages.length,
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20),
          itemBuilder: (context, index) {
            final message = _messageController.messages[index];
            return MessageTileGroup(
              message: message.text,
              sender: message.senderName,
              sendByMe: message.senderId == currentUserId ? true : false,
            );
          },
        ),
      );
    });
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
      GroupMessageController(groupId: widget.chatId).sendMessageToGroup(widget.chatId, message );
      setState(() {
        messageBox.clear();
      });
    }
  }

  void _onFocusChange() {
    if (_messageFocusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        scrollToBottom();
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
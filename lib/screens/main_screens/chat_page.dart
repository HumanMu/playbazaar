import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/message_controller/message_controller.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../models/message_model.dart';
import '../widgets/cards/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String userName;
  final String? recieverId;


  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.userName,
    this.recieverId,

  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final MessageController _messageController;
  late final ScrollController _scrollController;
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  String admin = "";


  @override
  void initState() {
    super.initState();
    _messageController = Get.put(MessageController(groupId: widget.chatId));
    _scrollController = ScrollController();

    // Listen to new messages and scroll to bottom when they arrive
    _messageController.listenToMessages(widget.chatId);
    ever(_messageController.messages, (_) => scrollToBottom());
  }

  @override
  void dispose() {
    messageBox.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.chatName),
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
            icon: const Icon(Icons.info, color: Colors.white70,),
          ),
        ],
      ),
      body: Column(
        children: [
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
                      sendMessage();
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

  sendMessage() {
    final messageLength = messageBox.text.length;
    if(messageLength > 1000) {
      showCustomSnackbar(
          "${"current_message_length".tr}: $messageLength "
              "${"allowed_message_length_1000".tr}", false, timing: 6
      );
      return;
    }
    if(messageBox.text.trim().isEmpty) {
      return;
    }

    Message message = Message(
        senderId: currentUserId!,
        senderName: widget.userName,
        text: messageBox.text,
        timestamp: Timestamp.now(),
        isSentByMe: true
    );
    MessageController(groupId: widget.chatId).sendMessageToGroup( message );
    setState(() {
      messageBox.clear();
    });

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
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
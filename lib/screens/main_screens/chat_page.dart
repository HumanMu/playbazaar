import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Firestore/firestore_groups.dart';
import '../../api/firestore/firestore_user.dart';
import '../secondary_screens/chat_info.dart';
import '../widgets/cards/message_tile.dart';
import '../widgets/text_boxes/text_widgets.dart';

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
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageBox = TextEditingController();
  Stream <QuerySnapshot> ? chats;
  String admin = "";


  @override
  void initState() {
    getChat();
    super.initState();
  }

  @override
  void dispose() {
    messageBox.dispose();
    super.dispose();
  }

  getChat() {
    widget.recieverId==null? FirestoreGroups().getChat(widget.chatId).then((val) {
        setState(() {
          chats = val;
        });
      }) : FirestoreUser(userId: currentUserId).getChat( widget.recieverId).then((val) {
      setState(() {
        chats = val;
      });
    });


    FirestoreGroups(userId: currentUserId).getGroupAdmin(widget.chatId).then((val) {
      setState(() {
        admin = val;
      });
    });
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
              navigateToAnotherScreen(context, ChatInfo(
                chatId: widget.chatId,
                chatName: widget.chatName,
                adminName: admin,
              ));
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessage(),
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

  chatMessage() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData 
          ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sendByMe: widget.userName == snapshot.data.docs[index]['sender'],
              );
            },
        ) : Container();
      }
    );
  }

  sendMessage() {
    if(messageBox.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageBox.text,
        "sender" : widget.userName,
        "time" : DateTime.now().millisecondsSinceEpoch,
      };
      widget.recieverId == null?
           FirestoreGroups().sendMessage( widget.chatId, chatMessageMap)
          : FirestoreUser(userId:currentUserId).sendMessage(widget.recieverId, chatMessageMap);

    }
    setState(() {
      messageBox.clear();
    });
  }
}
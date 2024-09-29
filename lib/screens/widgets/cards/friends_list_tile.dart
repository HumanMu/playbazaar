import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/sharedpreferences.dart';
import '../../main_screens/chat_page.dart';
import '../text_boxes/text_widgets.dart';

class FriendsListTile extends StatefulWidget {
  final String friendId;
  final String firstname;
  final String lastname;
  final String availabilityState;

  const FriendsListTile({super.key,
    required this.friendId,
    required this.firstname,
    required this.lastname,
    required this.availabilityState,
  });

  @override
  State<FriendsListTile> createState() => _FriendsListTile();
}

class _FriendsListTile extends State<FriendsListTile> {
  String currentUserName = "";

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    final value = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey);
    if(value != null && value != "") {
      setState(() {
        currentUserName = value;
      });
    }
    else {
      currentUserName = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() {
        navigateToAnotherScreen(context, ChatPage(
          chatId: widget.friendId,
          chatName: widget.firstname,
          userName: currentUserName,
          recieverId: widget.friendId,
        ));
      },

      child: Container(
        color: Colors.white70,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.red,
            child: Text(
              widget.firstname.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          title:Text("${widget.firstname} ${widget.lastname}",
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              widget.availabilityState == "Online"
              ?Text('online'.tr, style: const TextStyle(color: Colors.green, fontSize: 11))
              :Text('offline'.tr, style: const TextStyle(color: Colors.black, fontSize: 12)),
            ]
          ),
        ),
      )
    );
  }
}
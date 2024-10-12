import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main_screens/chat_page.dart';
import '../text_boxes/text_widgets.dart';

class FriendsListTile extends StatefulWidget {
  final String friendId;
  final String fullame;
  final Function()? onTap;
  final String? availabilityState;

  const FriendsListTile({super.key,
    required this.friendId,
    required this.fullame,
    this.onTap,
    this.availabilityState,
  });

  @override
  State<FriendsListTile> createState() => _FriendsListTile();
}

class _FriendsListTile extends State<FriendsListTile> {
  String currentUserName = "";


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.white70,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.red,
            child: Text(
              widget.fullame.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          title:Text(widget.fullame,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Text("${"status".tr}:"),
              const SizedBox(width: 10),
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
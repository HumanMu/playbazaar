import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/enums.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import '../../../functions/string_cases.dart';
import '../../../models/DTO/search_friend_dto.dart';
import '../../../models/friend_model.dart';

class SearchFriendTile extends StatefulWidget {
  final SearchFriendDto searchData;
  final int index;

  const SearchFriendTile({
    super.key,
    required this.searchData,
    required this.index,
  });

  @override
  State<SearchFriendTile> createState() => _SearchFriendTileState();
}

class _SearchFriendTileState extends State<SearchFriendTile> {
  String buttonText = '';
  Color buttonColor = Colors.green;
  VoidCallback? buttonAction;

  @override
  void initState() {
    super.initState();
    _setUpButtonState();
  }

  void _setUpButtonState() {
    final userController = Get.find<UserController>();

    switch (widget.searchData.requestStatus) {
      case "Friend":
        buttonText = 'friend'.tr;
        buttonColor = Colors.white;
        buttonAction = null;
        break;
      case "WaitingAnswer":
        buttonText = 'btn_cancel_request'.tr;
        buttonColor = Colors.orange;
        buttonAction = () async {
          await userController.cancelFriendRequest(widget.searchData.foreignId);
          setState(() {
            buttonText = 'request_cancelled'.tr;
            buttonColor = Colors.white;
            buttonAction = null;
          });
        };
        break;
      case "ReceivedRequest":
        buttonText = 'btn_approve_request'.tr;
        buttonColor = Colors.orange;
        buttonAction = () async {
          await userController.acceptFriendRequest(widget.searchData.foreignId);
          setState(() {
            buttonColor = Colors.white70;
            buttonText = 'friend'.tr;
            buttonAction = null;
          });
        };
        break;
      default: // "NoRequest"
        buttonText = 'btn_request_friendship'.tr;
        buttonColor = Colors.green;
        buttonAction = () async {
          FriendModel friendRequest = FriendModel(
            senderId: widget.searchData.currentUserId,
            uid: widget.searchData.foreignId,
            fullname: widget.searchData.fullname,
            avatarImage: "",
            friendshipStatus: FriendshipStatus.waiting,
            chatId: '',
          );

          await userController.sendFriendRequest(friendRequest, widget.index);

          setState(() {
            buttonText = 'request_sent'.tr;
            buttonColor = Colors.white70;
            buttonAction = null; // Disable button after sending request
          });
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchData.currentUserId == widget.searchData.foreignId) {
      return const Text(""); // Skip rendering the tile for the current user
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.red,
        child: Text(
          widget.searchData.fullname.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        capitalizeFirstLetter(widget.searchData.fullname),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: InkWell(
        onTap: buttonAction,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: buttonColor,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';

class FriendsListTile extends StatefulWidget {
  final String friendId;
  final String fullname;
  final Function()? onTap;
  final String? lastMessage;

  const FriendsListTile({
    super.key,
    required this.friendId,
    required this.fullname,
    this.onTap,
    this.lastMessage,
  });

  @override
  State<FriendsListTile> createState() => _FriendsListTile();
}

class _FriendsListTile extends State<FriendsListTile> {
  final UserController userController = Get.find<UserController>();
  final HiveUserService hiveUserService = Get.find<HiveUserService>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),

      child: InkWell( // Replace GestureDetector with InkWell
        onTap: widget.onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          dense: true,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.red,
            child: Text(
              widget.fullname.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          title: Text(
            capitalizeFullname(widget.fullname),
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
            subtitle: Row(
              children: [
                Flexible(
                  child: widget.lastMessage == 'say*hi'
                      ? Text(
                    '${"say_hi".tr} ${capitalizeFirstName(widget.fullname)}',
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  )
                      : Text(
                    widget.lastMessage ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteFriendship() async {
    try {
      bool deleteResult = await userController.removeFriendById(widget.friendId);

      if (deleteResult) {
        await hiveUserService.deleteRecentUser(widget.friendId);

        // Update the UI state in UserController
        userController.searchedFriends.removeWhere((friend) => friend.uid == widget.friendId);

        showCustomSnackbar("${widget.fullname} ${"removed_from_friends".tr}", true);
      } else {
        showCustomSnackbar("unexpected_result".tr, false);
      }
    } catch (e) {
      showCustomSnackbar("error_deleting_friend".tr, false);
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text("${"delete_friendship".tr}: ${capitalizeFullname(widget.fullname)}"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFriendship();
                },
              ),
            ],
          ),
        );
      },
    );
  }

}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';

class FriendsListTile extends StatefulWidget {
  final String friendId;
  final String fullname;
  final Function()? onTap;
  final String? availabilityState;

  const FriendsListTile({
    super.key,
    required this.friendId,
    required this.fullname,
    this.onTap,
    this.availabilityState,
  });

  @override
  State<FriendsListTile> createState() => _FriendsListTile();
}

class _FriendsListTile extends State<FriendsListTile> {
  final UserController userController = Get.find<UserController>();
  String currentUserName = "";

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text("${"delete_friendship".tr}: ${widget.fullname}"),
                onTap: () {
                  // Handle delete friendship logic here
                  Navigator.pop(context); // Close the menu
                  _deleteFriendship(); // Call your delete method
                },
              ),
              // You can add more options here if needed
            ],
          ),
        );
      },
    );
  }

  void _deleteFriendship() async {
    bool deleteResult = await userController.removeFriendById(widget.friendId);
    if(deleteResult){
      showCustomSnackbar("${widget.fullname} ${"removed_from_friends".tr}", true);
    }
    else{
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
            ),
          ),
          subtitle: Row(
            children: [
              Text("${"status".tr}:"),
              const SizedBox(width: 10),
              widget.availabilityState == "Online"
                  ? Text('online'.tr, style: const TextStyle(color: Colors.green, fontSize: 11))
                  : Text('offline'.tr, style: const TextStyle(color: Colors.black, fontSize: 12)),
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
}
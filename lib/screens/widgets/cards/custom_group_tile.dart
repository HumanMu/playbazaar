import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/string_cases.dart';
import '../../../utils/text_boxes/text_box_decoration.dart';
import '../dialogs/accept_result_dialog.dart';


class CustomGroupTile extends StatefulWidget {
  final String admin;
  final String groupId;
  final String groupName;
  final String? password;

  const CustomGroupTile({super.key,
    required this.groupId,
    required this.groupName, 
    required this.admin,
    this.password

  });

  @override
  State<CustomGroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<CustomGroupTile> {
  String onlineStatus = "";
  bool isLoading = false;
  final groupPasswordController = TextEditingController();
  String enteredPassword = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() {
        groupPasswordController.text = "";
        if(widget.password == null){
          Get.toNamed('/chat', arguments: {
            'chatId': widget.groupId,
            'chatName': widget.groupName,
            'userName': widget.admin,
          });
        }else{
          _dialogBuilder(context);
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.red,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          title: Text(capitalizeFirstLetter(widget.groupName),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(widget.password?.trim() == null
              ? "${"group".tr}: ${"public".tr}"
              : "${"group".tr}: ${"private".tr}",
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  bool identifyPassword(enteredPassword) {
    bool result = enteredPassword == widget.password ? true: false;
    return result;
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String title = "password".tr;
        return AlertDialog(
          title: Text('enter_group_password'.tr),
          content: TextField(
            obscureText: true,
            controller: groupPasswordController,
            onChanged: (val) {
              enteredPassword = val;
              setState(() {});
            },
            decoration: decoration(title),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(5.0),
                textStyle: const TextStyle(fontSize: 15),
              ),
              child: Text('btn_cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(5.0),
                textStyle: const TextStyle(fontSize: 15),
              ),
              child: Text('btn_login'.tr),
              onPressed: () {
                Navigator.of(context).pop();
                bool result = identifyPassword(enteredPassword);
                if(result == true){
                  Get.toNamed('/chat', arguments: {
                    'chatId': widget.groupId,
                    'chatName': widget.groupName,
                    'userName': widget.admin,
                  });
                }
                else{
                  acceptResultDialog(context, "", 'wrong_group_password'.tr);
                }
              },
            ),
          ],
        );
      },
    );
  }

}

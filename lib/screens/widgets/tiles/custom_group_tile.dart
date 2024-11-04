import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/helper/encryption/encrypt_string.dart';
import 'package:playbazaar/models/group_model.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../../models/DTO/add_group_member.dart';
import '../../../utils/text_boxes/text_box_decoration.dart';
import '../dialogs/accept_result_dialog.dart';
import '../dialogs/leaving_group_dialog.dart';


class CustomGroupTile extends StatefulWidget {
  final String admin;
  final String groupId;
  final String groupName;
  final bool isPublic;

  const CustomGroupTile({super.key,
    required this.groupId,
    required this.groupName, 
    required this.admin,
    required this.isPublic,

  });

  @override
  State<CustomGroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<CustomGroupTile> {
  final GroupController groupController = Get.put(GroupController());
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String onlineStatus = "";
  bool isLoading = false;
  final groupPasswordController = TextEditingController();
  String enteredPassword = "";
  late GroupModel requestedGroup;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    groupPasswordController.dispose();
    super.dispose();
  }


  Future<void> retreiveTheGroup() async {
    setState(() {
      isLoading = true;
    });
    final groupResult = await groupController.getGroupById(widget.groupId);

    setState(() {
      requestedGroup = GroupModel.fromMap(groupResult.data() as Map<String, dynamic>);
      isLoading = false;
    });
  }

  bool canAccessTheGroup() {
    if (requestedGroup.members.isNotEmpty && isGroupMember(requestedGroup.members)) {
      _dialogBuilder(context);
      return true;
    } else {
      showCustomSnackbar("not_group_member".tr, false);
      return false;
    }
  }
  
  bool isGroupMember(List<String> members) {
    for(String member in members){
      String memberId = splitByUnderscore(member)[0];
      if(memberId == currentUserId){
        return true;
      }
    }
    return false;
  }

  void navigateToGroupChat() {
    Get.toNamed('/group_chat', arguments: {
      'chatId': widget.groupId,
      'chatName': widget.groupName,
      'userName': widget.admin,
    });
  }

  bool isPublic() {
    return requestedGroup.isPublic? true : false;
  }



  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap:() async {
        await retreiveTheGroup();
        groupPasswordController.text = "";
        if(isPublic()){
          navigateToGroupChat();
        }else {
          canAccessTheGroup();
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
          subtitle: Text(widget.isPublic
              ? "${"group".tr}: ${"public".tr}"
              : "${"group".tr}: ${"private".tr}",
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: (){
              leavingGroupDialog(_handleLeaveGroup);
            }
          ),
        ),
      ),
    );
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
                identifyPassword();
              },
            ),
          ],
        );
      },
    );
  }

  void identifyPassword() async {
    try {
      String decryptedPas = await EncryptionHelper.decryptPassword(requestedGroup.groupPassword);

      bool result = groupPasswordController.text == decryptedPas;
      result ? navigateToGroupChat() : showErrorDialog();
    } catch (e) {
      showErrorDialog();
    }
  }

  void showErrorDialog(){
    acceptResultDialog(context, "", 'wrong_group_password'.tr);
  }

  Future<void> _handleLeaveGroup() async {
    AddGroupMemberDto memberDto = AddGroupMemberDto(
        groupId: widget.groupId,
        userName: widget.admin,
        groupName: widget.groupName,
        isPublic: widget.isPublic
    );

    groupController.removeGroupFromUser(
        memberDto,
        FirebaseAuth.instance.currentUser!.uid)
        .whenComplete(() {
      Get.offNamed('/home');
    });
  }

}

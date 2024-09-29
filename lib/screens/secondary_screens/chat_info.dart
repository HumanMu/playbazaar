import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/models/DTO/membership_toggler_model.dart';
import '../../controller/group_controller/group_info_controller.dart';

class ChatInfo extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String adminName;

  const ChatInfo({ super.key,
    required this.chatId,
    required this.chatName,
    required this.adminName,

  });

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  final GroupInfoController controller = Get.put(GroupInfoController());

  @override
  void initState() {
    controller.getMember(widget.chatId);
    super.initState();
  }

  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.red,
          title: Text("about_this_group".tr),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("leaving".tr),
                        content: Text("leaving_group".tr,
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel_presentation, color: Colors.red,),
                          ),
                          IconButton(
                              onPressed: () async {
                                MembershipTogglerModel toggle = MembershipTogglerModel(
                                    groupId: widget.chatId,
                                    userName: getName(widget.adminName),
                                    groupName: widget.chatName
                                );
                                await GroupController().toggleGroupMembership(
                                    toggle,
                                    FirebaseAuth.instance.currentUser!.uid)
                                    .whenComplete(() {
                                  Get.offNamed('/home');
                                });
                              }, icon: const Icon(
                              Icons.done_outline, color: Colors.green)
                          ),
                        ],);
                    }
                );
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme
                        .of(context)
                        .primaryColor
                        .withOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: const AssetImage(
                            'assets/icons/kingCrown.jpeg'),
                        child: Text(
                          widget.chatName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("group".tr + widget.chatName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          controller.groupMembers.isNotEmpty? Text("group_admin".tr +
                             getName(controller.groupMembers[0]),
                          ) : Text("N/A"),

                        ],
                      ),
                    ],
                  ),
                ),
                groupMemberList(),
              ],
              )
          ),
        ),
      );
    });
  }


  groupMemberList () {
      if (controller.groupMembers.isEmpty) {
        return Center(
          child: Text("members_notfound".tr),
        );
      }

      return ListView.builder(
        itemCount: controller.groupMembers.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var member = controller.groupMembers[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                child: Text(
                  getName(member).substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(getName(member)),
            ),
          );
        },
      );
  }
}
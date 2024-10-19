import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/helper/sharedpreferences/sharedpreferences.dart';
import 'package:playbazaar/models/DTO/group_detail_dto.dart';
import 'package:playbazaar/models/DTO/add_group_member.dart';
import '../../controller/group_controller/group_info_controller.dart';
import '../widgets/dialogs/leaving_group_dialog.dart';

class ChatInfo extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String adminName;
  final bool isPublic;

  const ChatInfo({ super.key,
    required this.chatId,
    required this.chatName,
    required this.adminName,
    required this.isPublic,
  });

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  late String userName = "";
  late GroupInfoController groupInfoController;
  late GroupController groupController;
  late DocumentSnapshot docSnap;
  late List<GroupDetailDto> groupDetail = [];
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Get.create(() => GroupInfoController());
    Get.create(() => GroupController());

    groupInfoController = Get.find<GroupInfoController>();
    groupController = Get.find<GroupController>();
    initData();
  }

  @override
  void dispose() {
    Get.delete<GroupInfoController>();
    Get.delete<GroupController>();
    super.dispose();


  }

  void initData() async{
    userName = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey) ?? "";
    docSnap = await groupController.getGroupById(widget.chatId);
    String groupAdmin = splitByUnderscore(docSnap['creatorId'])[1];

    for(var member in docSnap['members']) {
      GroupDetailDto newGroup = GroupDetailDto(
        groupId: splitByUnderscore(member)[0],
        groupName: docSnap['name'],
        memberName: splitByUnderscore(member)[1],
        adminName: groupAdmin,
      );
      groupDetail.add(newGroup);
    }
    setState(() {
      isLoading = false;
    });
  }

  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
        title: Text("about_this_group".tr,
          style: TextStyle(color: Colors.white)
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        actions: [
          IconButton(
            onPressed: () {
              leavingGroupDialog(_handleLeaveGroup);
            },
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white
            ),
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
                          'assets/icons/kingCrown.jpeg'
                      ),
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
                        Text("group".tr + capitalizeFirstLetter(widget.chatName),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        groupDetail.isNotEmpty? Text("group_admin".tr +
                           getName(groupDetail[0].adminName),
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
  }


  groupMemberList () {
      if (groupDetail.isEmpty) {
        return Center(
          child: Text("members_notfound".tr),
        );
      }

      return ListView.builder(
        itemCount: groupDetail.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                child: Text(
                  getName(groupDetail[index].memberName).substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(getName(groupDetail[index].memberName)),
            ),
          );
        },
      );
  }

  Future<void> _handleLeaveGroup() async {
    if (!mounted) return;

    AddGroupMemberDto memberDto = AddGroupMemberDto(
      groupId: widget.chatId,
      userName: widget.adminName,
      groupName: widget.chatName,
      isPublic: widget.isPublic,

    );

    groupController.removeGroupFromUser(
        memberDto,
        FirebaseAuth.instance.currentUser!.uid)
        .whenComplete(() {
      Get.offNamed('/home');
    });
  }
}
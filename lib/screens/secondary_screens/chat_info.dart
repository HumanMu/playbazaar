import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/models/DTO/membership_toggler_model.dart';
import '../../api/Firestore/firestore_groups.dart';

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
  Stream? members;

  @override
  void initState() {
    getMember();
    super.initState();
  }
  getMember() async {
    FirestoreGroups(userId: FirebaseAuth.instance.currentUser!.uid)
    .getGroupMember(widget.chatId).then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () { Navigator.pop(context);    },
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
                          await GroupController().toggleGroupMembership(toggle,
                              FirebaseAuth.instance.currentUser!.uid )
                              .whenComplete((){
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
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: const AssetImage('assets/icons/kingCrown.jpeg'),
                          child: Text(
                            widget.chatName.substring(0,1).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("group".tr + widget.chatName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Text("group_admin".tr + getName(widget.adminName),
                              //textAlign: TextAlign.right,
                              //textDirection: TextDirection.rtl,
                            ),

                          ],
                        ),
                       ],
                    ),
                  ),
                  memberList(),
                ],
              )
          ),
        ),
    );
  }

  memberList () {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if(snapshot.hasData && snapshot.data.exists) {
            if(snapshot.data["members"] != null) {
              if(snapshot.data["members"].length != 0){
                return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Text(
                            getName(snapshot.data["members"][index]).substring(0,1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(getName(snapshot.data["members"][index])),
                        subtitle: Text(getId(snapshot.data["members"][index])),
                      ),
                    );
                  }
                );
              }
              else {
                return Center(
                  child: Text("members_notfound".tr),
                );
              }
            }
            else{
              return Center(
                child: Text("members_notfound".tr),
              );
            }
          }
          else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
        }
      )
    );
  }
}
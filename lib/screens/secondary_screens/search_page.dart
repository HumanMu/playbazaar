import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/Firestore/firestore_groups.dart';
import '../../api/firestore/firestore_user.dart';
import '../../api/services/notification_services.dart';
import '../../helper/sharedpreferences.dart';
import '../main_screens/chat_page.dart';
import '../widgets/text_boxes/text_widgets.dart';

class SearchPage extends StatefulWidget {
  final String searchId;
  const SearchPage({super.key, required this.searchId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  String userName = "";
  User? user;
  bool hasUserSearched = false;
  bool userIsAMemberOfTheGroup = false;
  String? friendShipStatus;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  Future<void> getCurrentUserIdAndName() async {
    final value = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey);
    if(value != null && value != "") {
      setState(() {
        userName = value;
      });
    }
    else {
      userName = "";
    }

    user = FirebaseAuth.instance.currentUser;
  }
  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }


  @override
  Widget build(BuildContext context) {
    final searchId = widget.searchId =="group" ?  "search_groups".tr
        : 'search_friends'.tr;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("search".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15 ),
            child: Row(
              children: [
                Expanded( // Search field
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: searchId,
                      hintStyle: const TextStyle(
                        color: Colors.white, fontSize: 15,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearch(searchId);
                  },
                  child: Container(
                    width: 45,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: AvatarGlow(
                      startDelay: const Duration(milliseconds: 2000),
                      glowShape: BoxShape.circle,
                      curve: Curves.fastOutSlowIn,
                      glowColor: Colors.grey,
                       child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor ),
          ) : searchedResultList(),
        ],
        ),
      ),
    );
  }

  initiateSearch(searchId) async {
    if(searchController.text.isNotEmpty) {
      setState(() { isLoading = true; });
      if(searchId = widget.searchId =="group") {
        await FirestoreGroups()
            .searchByGroupName(searchController.text)
            .then((snapshot) {
          setState(() {
            searchSnapshot = snapshot;
            isLoading = false;
            hasUserSearched = true;
          });
        });
      }
      else{
         await FirestoreGroups()  // Search for a user
          .searchByUserName(searchController.text)
          .then((snapshot) {
            setState(() {
              searchSnapshot = snapshot;
              isLoading = false;
              hasUserSearched = true;
            });
          });
      }
    }
  }


  searchedResultList() {
    return hasUserSearched 
      ? ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context, index) {
          return widget.searchId=="group"? searchGroupTile(
            userName, 
            searchSnapshot!.docs[index]['groupId'],
            searchSnapshot!.docs[index]['groupName'],
            searchSnapshot!.docs[index]['admin'],
          ) : searchFriendTile(
            user!.uid,
            searchSnapshot!.docs[index]['uid'],
            searchSnapshot!.docs[index]['firstname'],
            searchSnapshot!.docs[index]['lastname']
          );
        },
    ) : Container();
  }

  Widget searchFriendTile(String userId, String foreignId,
      String foreignName, String foreignLastname) {
    // Check if user already is a friend
    friendshipCheck(userId, foreignId);

    if(userId == foreignId){
      return const Text("");
    }
    // Show the founded users
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.red,
        child: Text(foreignName.substring(0,1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      title: Text("$foreignName $foreignLastname", style: const TextStyle(fontWeight: FontWeight.bold )),
      trailing: InkWell(
        onTap: () async {
          await FirestoreUser(userId: user!.uid)
              .sendFriendRequest(user!.uid, foreignId);
        },
        child: friendShipStatus =="WaitingAnswer"  || friendShipStatus == "TheyAreFriends"? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.lightGreen,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: friendShipStatus =="TheyAreFriends"? Text('friends'.tr) : Text('delete_friend'.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ) : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('request_friendship'.tr,
                style: const TextStyle( color: Colors.white ),
              ),
        ),
      ),
    );
  }

  Widget searchGroupTile(String userName, String groupId, String groupName, String admin) {
     // Check if user already is a member of the group
    joinedGroupMembers(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.red,
        child: Text(groupName.substring(0,1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold, )),
      subtitle: Text("group_admin".tr + getName(admin),
      ),
      trailing: InkWell(
        onTap: () async {
          await FirestoreGroups(userId: user!.uid)
          .toggleGroupMembership(groupId, userName, groupName);

          if(userIsAMemberOfTheGroup) {
            setState(() {
              userIsAMemberOfTheGroup = !userIsAMemberOfTheGroup;
            });
            if(mounted){
              showSnackBar(context, "group_membershit_succed".tr, Colors.green);
            }
            Future.delayed(const Duration(seconds: 3), () {
              navigateToAnotherScreen(context, ChatPage(
                chatId: groupId,
                chatName: groupName,
                userName: userName,
                //recieverId: "",
              )
              );
            });
          }
          else {
            setState(() {
              userIsAMemberOfTheGroup = !userIsAMemberOfTheGroup;
            });
            if(mounted) {
              showSnackBar(context, "leaving_group_succed".tr, Colors.red);
            }
          }
        },
        child: userIsAMemberOfTheGroup ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.lightGreen,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("btn_leaving_group".tr,
            style: const TextStyle(color: Colors.white),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("btn_membershipt_request".tr  , style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  joinedGroupMembers(String userName, String groupId, String groupName, String admin) async {
    await FirestoreGroups(userId: user!.uid)
    .checkIfUserJoined(groupName, groupId, userName)
    .then((val){
      setState(() {
        userIsAMemberOfTheGroup = val;
      });
    });
  }

  friendshipCheck(String userId, String foreignId) async {
    userId != foreignId? await FirestoreUser(userId: userId)
      .checkIfUserAlreadyFriends( userId,foreignId)
      .then((val){
        setState(() {
          friendShipStatus = val;
        });
    }) : "";
  }
}
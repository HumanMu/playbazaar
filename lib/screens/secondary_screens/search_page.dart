import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/models/DTO/membership_toggler_model.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../api/Firestore/firestore_groups.dart';
import '../../api/firestore/firestore_user.dart';
import '../../api/services/notification_services.dart';
import '../../helper/sharedpreferences.dart';

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
          if(widget.searchId == 'group') {
            MembershipTogglerModel toggle = MembershipTogglerModel(
              userName: userName,
              groupId: searchSnapshot!.docs[index]['groupId'],
              groupName: searchSnapshot!.docs[index]['name'],
            );
            return searchGroupTile(
              toggle,
              searchSnapshot!.docs[index]['admin'],
            );
          } else{
            return searchFriendTile(
                user!.uid,
                searchSnapshot!.docs[index]['uid'],
                searchSnapshot!.docs[index]['firstname'],
                searchSnapshot!.docs[index]['lastname']
            );
          }
        },
    ) : Container();
  }

  Widget searchFriendTile(String userId, String foreignId,
      String foreignName, String foreignLastname) {
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

  Widget searchGroupTile(MembershipTogglerModel toggle, String admin) {
    joinedGroupMembers(toggle, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.red,
        child: Text(toggle.groupName.substring(0,1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      title: Text(toggle.groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold)
      ),
      subtitle: Text("group_admin".tr + getName(admin),
      ),
      trailing: InkWell(
        onTap: () async {
          await GroupController().toggleGroupMembership(toggle, FirebaseAuth.instance.currentUser!.uid);
          if(mounted && userIsAMemberOfTheGroup) {
            setState(() {
              userIsAMemberOfTheGroup = !userIsAMemberOfTheGroup;
            });
            showSnackBar(context, "group_membershit_succed".tr, Colors.green);
            Future.delayed(const Duration(seconds: 3), () {
              Get.toNamed('/chat', arguments: {
                'chatId': toggle.groupId,
                'chatName': toggle.groupName,
                'userName': userName,
                'recieverId': '',
              });
            });
          }
          else {
            setState(() {
              userIsAMemberOfTheGroup = !userIsAMemberOfTheGroup;
            });
            showCustomSnackbar("leaving_group_succed".tr, false);
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

  joinedGroupMembers(MembershipTogglerModel toggle,  String admin) async {
    await GroupController().checkIfUserJoined(toggle)
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
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/group_controller/group_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/screens/widgets/tiles/search_friend_tile.dart';
import '../../api/Firestore/firestore_groups.dart';
import '../../models/DTO/add_group_member.dart';
import '../../models/DTO/search_friend_dto.dart';

class SearchPage extends StatefulWidget {
  final String searchId;
  const SearchPage({super.key, required this.searchId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final UserController userController = Get.find<UserController>();
  late GroupController groupController;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  User? user;
  bool hasUserSearched = false;
  bool userIsAMemberOfTheGroup = false;
  String? friendShipStatus;

  @override
  void initState() {
    super.initState();
    Get.put(GroupController());
    //Get.create(() => GroupController());
    //groupController = Get.find<GroupController>();
  }

  @override
  void dispose() {
    searchController.dispose();
    Get.delete<GroupController>();
    super.dispose();
  }



  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    final searchId = widget.searchId =="group"
        ? "search_groups".tr
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
        iconTheme: IconThemeData(
          color: Colors.white
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
          Obx(() {
            if (userController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if (widget.searchId == "group") {
              return searchedGroupList();
            } else {
              return searchedFriendList();
            }
          }),
        ],
        ),
      ),
    );
  }

  initiateSearch(searchId) async {
    if(searchController.text.trim().isNotEmpty) {
      setState(() { isLoading = true; });
      if( widget.searchId =="group") {
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
        await userController.searchUserByName(searchController.text.trim());
        setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      }
    }
  }

  searchedFriendList() {
    return hasUserSearched
        ? userController.searchedUsersList.isEmpty
        ? Center(child: Text("search_not_found".tr))
        : ListView.builder(
          shrinkWrap: true,
          itemCount: userController.searchedUsersList.length,
          itemBuilder: (context, index) {
            final searched = userController.searchedUsersList[index];
            String friendStatus = "NoRequest";

            // Reactive data access
            if (userController.friendList.any((friend) => friend['uid'] == searched['uid'])) {
              friendStatus = "Friend";
            } else if (userController.sentFriendRequests.any((request) => request['uid'] == searched['uid'])) {
              friendStatus = "WaitingAnswer";
            } else if (userController.recievedFriendRequests.any((request) => request['uid'] == searched['uid'])) {
              friendStatus = "ReceivedRequest";
            }

            SearchFriendDto searchedResult = SearchFriendDto(
              userId: FirebaseAuth.instance.currentUser!.uid,
              foreignId: searched['uid'],
              fullname: searched['fullname'],
              requestStatus: friendStatus,
            );

            return SearchFriendTile(searchData: searchedResult, index: index);
          },
        ): Container();
  }

  searchedGroupList() {
    return hasUserSearched
      ? searchSnapshot!.docs.isEmpty
      ? Center(child: Text("search_not_found".tr))
      : ListView.builder(
          shrinkWrap: true,
          itemCount: searchSnapshot!.docs.length,
          itemBuilder: (context, index) {
            var searchedGroup = searchSnapshot!.docs[index];
            final currentGroupsId = userController.userData.value?.groupsId ?? [];

            bool isMember = currentGroupsId.any((groupIdName) {
              String id = groupIdName.split('_').first;
              return id == searchedGroup['groupId'];
            });
            bool isPublic = searchedGroup['isPublic'];

            AddGroupMemberDto addGroup = AddGroupMemberDto(
              groupId: searchedGroup['groupId'],
              groupName: capitalizeFirstLetter(searchedGroup['name']),
              userName: searchedGroup['creatorId'],
            );
            return searchGroupTile(addGroup, isMember, isPublic);
          }
    ) : Container();
  }


  Widget searchGroupTile(AddGroupMemberDto addGroup, bool isMember, isPublic) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red,
          child: Text(addGroup.groupName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          addGroup.groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
        subtitle: isPublic
            ? Text("${"group".tr}: ${"public".tr}")
            : Text("${"group".tr}: ${"private".tr}"),
        trailing: InkWell(
          onTap: () async {
            if(!isMember){
              await addGroupMember(addGroup);
              setState(() {
                isMember = true;
              });
            }
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isMember
                    ? Colors.white
                    : Colors.red
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Text(
                isMember
                    ? "already_member".tr
                    : "btn_membership_request".tr,
                style: const TextStyle(color: Colors.black),
              ),
          ),
        ),
      );
  }

  Future<void> addGroupMember(AddGroupMemberDto addGroup) async{
    await GroupController().addGroupMember(addGroup);
  }

}
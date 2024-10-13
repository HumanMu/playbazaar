import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import '../widgets/cards/friends_list_tile.dart';
import '../widgets/cards/recieved_requests_tile.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  final UserController userController = Get.find<UserController>();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  String userEmail = "";
  Stream? friendRequests;


  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(
                  '/search',
                  arguments: {'searchId': 'friends'}
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("my_friends".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
              fontSize: 30
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),

      body: Material(
        color: Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            readFriendRequestsList(),
            friendList(),
          ],
        ),
      ),
    );
  }

  Widget friendList() {

    return Obx(() {
      if (userController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (userController.friendList.isEmpty) {
        return Center(
          child: Text("search_not_found".tr),
        );
      }

      return Flexible(
        child: SingleChildScrollView(
          child: ListView.builder(
            itemCount: userController.friendList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var friend = userController.friendList[index];
              return FriendsListTile(
                friendId: friend['uid'],
                fullame: friend['fullname'],
                onTap : () => goToChat(friend['uid'], friend['fullname']),
                availabilityState: '',
              );
            },
          ),
        ));
    });
  }

  goToChat(String friendId, String recieverName) {
    String username = FirebaseAuth.instance.currentUser?.displayName ?? "";
    Get.toNamed('/chat', arguments: {
      'chatId' : friendId,
      'chatName' : recieverName,
      'userName' : username,
      'recieverId' : friendId
    });
  }


  Widget readFriendRequestsList() {
    return Obx(() {
      if (userController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (userController.recievedFriendRequests.isEmpty) {
        return Container();
      }
      return Flexible(
          child: ListView.builder(
            itemCount: userController.recievedFriendRequests.length,
            itemBuilder: (context, index) {
              var friend = userController.recievedFriendRequests[index];

              return RecievedRequestsTile(
                fullname: friend.fullname,
                avatarImage: friend.avatarImage,
                acceptAction: () => accept(friend.uid),
                declineAction: () => decline(friend.uid),
              );
            }
          )
      );
    });
  }


  accept(String friendId) async {
    await userController.accept(friendId);
  }
  decline(String userId) async {
    await userController.decline(userId);
  }


}

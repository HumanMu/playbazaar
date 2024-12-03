import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/enum_converter.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../constants/enums.dart';
import '../../controller/message_controller/private_message_controller.dart';
import '../../services/hive_services/hive_user_service.dart';
import '../widgets/tiles/recieved_requests_tile.dart';
import '../widgets/text_boxes/text_inputs.dart';
import '../widgets/tiles/friends_list_tile.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  final UserController userController = Get.find<UserController>();
  final PrivateMessageController pvMsgController = Get.put(PrivateMessageController());
  final HiveUserService _hiveUserService = Get.find();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late TextEditingController searchController = TextEditingController();
  String userName = "";
  String userEmail = "";
  Stream? friendRequests;
  bool hasSearched = false;
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  String getName(String ind) {
    return ind.substring(ind.indexOf("_") + 1);
  }

  final List<FriendsCategory> categories = [
    FriendsCategory(title: 'btn_chats',
        icon: Icons.chat
    ),
    FriendsCategory(
      title: 'requests',
      icon: Icons.people_alt_rounded,
    ),
  ];

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
              Icons.person_add_alt_rounded,
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? Colors.red : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  categories[index].icon,
                                  color: isSelected ? Colors.red : Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  categories[index].title.tr,
                                  style: TextStyle(
                                    color: isSelected ? Colors.red : Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 7),
                SearchTextFormField(
                  controller: searchController,
                  labelText: 'search_in_friends'.tr,
                  onTap: () => searchInFriends(searchController.text),
                ),
                searchedFriends(),
                selectedCategoryIndex == 0? conversationList() : Container(),
                selectedCategoryIndex == 1? readFriendRequestsList() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchedFriends() {
    return Obx(() {
      if (hasSearched && userController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (hasSearched && userController.searchedFriends.isEmpty) {
        return Center(
          child: Text("msg_friend_not_found".tr),
        );
      }

      return Flexible(
          child: SingleChildScrollView(
            child: ListView.builder(
              itemCount: userController.searchedFriends.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var friend = userController.searchedFriends[index];
                return FriendsListTile(
                  friendId: friend.uid,
                  fullname: friend.fullname,
                  onTap : () => goToChat(
                      friend.uid,
                      friend.fullname,
                      friend.chatId,
                      friendShipState2String(friend.friendshipStatus)
                  ),
                  lastMessage: '',
                );
              },
            ),
          ));
    });
  }


  Widget conversationList() {
    return Obx(() {
      if (!_hiveUserService.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      final recentUsers = _hiveUserService.recentUsers;
      if (recentUsers.isEmpty) {
        return Container();
      }

      return Flexible(
        child: ListView.builder(
          itemCount: recentUsers.length,
          itemBuilder: (context, index) {
            final user = recentUsers[index];
            return FriendsListTile(
              friendId: user.uid,
              fullname: user.fullname,
              onTap: () => goToChat(
                  user.uid,
                  user.fullname,
                  user.chatId,
                  user.friendshipStatus
              ),
              lastMessage: user.lastMessage,
            );
          },
        ),
      );
    });

  }


  Future<void>searchInFriends(String friendsName) async {
    if(friendsName.trim() == "")return;
    bool searchResult = await userController.searchInFirestore(friendsName);
    if(!searchResult){
      setState(() {
        hasSearched = true;
      });
    }
  }


  void goToChat(String friendId, String receiverName, String? chatId, String friendStat) async {
    if(string2FriendshipState(friendStat) == FriendshipStatus.good){
      String username = FirebaseAuth.instance.currentUser?.displayName ?? "";
      await Get.toNamed(
        '/private_chat',
        arguments: {
          'chatId': chatId,
          'chatName': receiverName,
          'userName': username,
          'receiverId': friendId
        },
      );
    }else if (string2FriendshipState(friendStat) == FriendshipStatus.waiting){
      showCustomSnackbar("This user has not accepted your friend request yet", false);
      return;
    }
    else{
      showCustomSnackbar("Sorry, you may not be a friend with this user yet", false);
      return;
    }
  }

  Widget readFriendRequestsList() {
    return Obx(() {
      if (userController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      final requestedFriendship = userController.friendList.where(
              (friend) => friend.friendshipStatus == FriendshipStatus.received).toList();
      if (requestedFriendship.isEmpty) {
        return Center(child: Text('${'friend_request'.tr}  0'));
      }
      return Flexible(
          child: ListView.builder(
              itemCount: requestedFriendship.length,
              itemBuilder: (context, index) {
                var friend = requestedFriendship[index];

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
    await userController.acceptFriendRequest(friendId);
  }

  decline(String userId) async {
    await userController.declineFriendRequest(userId);
  }

}

class FriendsCategory {
  final String title;
  final IconData icon;

  FriendsCategory({
    required this.title,
    required this.icon,
  });
}

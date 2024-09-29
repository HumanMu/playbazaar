import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import '../../api/firestore/firestore_user.dart';
import '../../utils/show_custom_snackbar.dart';
import '../widgets/cards/friends_list_tile.dart';
import '../widgets/cards/recieved_requests_tile.dart';

class RecievedRequests extends StatefulWidget {
  const RecievedRequests({super.key});

  @override
  State<RecievedRequests> createState() => _RecievedRequestsState();
}

class _RecievedRequestsState extends State<RecievedRequests> {
  final UserController userController = Get.put(UserController());
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  String userEmail = "";
  Stream? friendRequests;


  @override
  void initState() {
    super.initState();
    getFriendRequests();
    getFriends();
    //getFriends();
  }

  getFriendRequests() async {
    friendRequests = await FirestoreUser(userId: currentUserId)
        .getFriendRequests();
  }

  getFriends() async {
    await userController.getFriendList(currentUserId);
  }

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
              Get.toNamed('/search', arguments: {'searchId': 'friends'});
            },icon: const Icon(Icons.search, color: Colors.white,),
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("my_friends".tr,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),

      body: Material(
        color: Colors.white10,
        child: Obx((){
          if(userController.isLoading.value) {
            return CircularProgressIndicator();
          }

          return Column(
            children: [
              readFriendRequestsList(),
              friendList(),
            ],
          );
        }),
      )
    );
  }

  friendList() {
    if (userController.friendList.isEmpty) {
      return Center(
        child: Text("members_notfound".tr),
      );
    }

    return ListView.builder(
      itemCount: userController.friendList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return FriendsListTile(
            friendId: userController.friendList[index]['uid'],
            firstname: userController.friendList[index]['firstname'],
            lastname: userController.friendList[index]['lastname'],
            availabilityState: userController.friendList[index]['availabilityState']
        );
      },
    );
  }


  readFriendRequestsList() {
    final collectionPath = FirebaseFirestore.instance.collection('users')
        .doc(currentUserId).collection('friendRequests');
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collectionPath.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if(snapshot.hasError || !snapshot.hasData) {
          return Text('unexpected_result'.tr);
        }
        if(snapshot.data!.size == 0){
          return const Center(child: Text(" "));
        }
        else{
          final requests = snapshot.data?.docs.reversed.toList();
          return Flexible(
              child: ListView.builder(
                itemCount: snapshot.data!.size,
                itemBuilder: (context, index){
                  var data = requests?[index];
                  return RecievedRequestsTile(
                    fullname: "${data?['firstname']}  ${data?['lastname']}",
                    availabilityState: data?['availabilityState'] == "Offline"? "offline".tr : "online".tr,
                    avatarImage: data?['avatarImage'],
                    acceptAction: () => accept(data?['uid']),
                    declineAction: () => decline(data?['uid']),
                  );
                }
            ),
          );
        }
      },
    );
  }

  accept(String friendId) async {
    final result = await FirestoreUser(userId: currentUserId).acceptFriendRequest(friendId);
    if(mounted && result){
      showCustomSnackbar("approved_friend_request".tr, true);
    }
    else{
      showCustomSnackbar("declined_friend_request".tr, false);
    }
  }

  decline(String friendId) async {
    await FirestoreUser(userId: currentUserId).declineFriendRequests(friendId);
    if(mounted){
      showCustomSnackbar("removed_from_friends".tr, true);
    }
    else{
      showCustomSnackbar("something_went_wrong".tr, false);
    }
  }

}

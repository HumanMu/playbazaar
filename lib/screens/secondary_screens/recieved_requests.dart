import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/screens/secondary_screens/search_page.dart';
import '../../api/firestore/firestore_user.dart';
import '../../utils/show_custom_snackbar.dart';
import '../widgets/cards/friends_list_tile.dart';
import '../widgets/cards/recieved_requests_tile.dart';
import '../widgets/text_boxes/text_widgets.dart';

class RecievedRequests extends StatefulWidget {
  const RecievedRequests({super.key});

  @override
  State<RecievedRequests> createState() => _RecievedRequestsState();
}

class _RecievedRequestsState extends State<RecievedRequests> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  String userEmail = "";
  Stream? friendRequests;
  Stream<DocumentSnapshot>? userFriends;


  @override
  void initState() {
    super.initState();
    getFriendRequests();
  }

  getFriendRequests() async {
    friendRequests = await FirestoreUser(userId: currentUserId)
        .getFriendRequests();
  }

  getFriends() async {
    userFriends = await FirestoreUser(userId: currentUserId)
        .getFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              navigateToAnotherScreen(context, const SearchPage(searchId:'friend'));
            },icon: const Icon(Icons.search),
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
          child: Column(
            children: [
              readFriendRequestsList(),
              friendList(),
            ],
          ),
      )
    );
  }

  friendList() {
    return StreamBuilder(
      stream: userFriends,
      builder: (context,  AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && !snapshot.hasError ) {
          final friendsId = snapshot.data!['friendsId'] as List<dynamic>;
          return ListView.builder(
              padding: const EdgeInsets.only(top: 0),
              itemCount: friendsId.length,
              itemBuilder: (context, index) {
                // Access the subcollection
                final friendRef = snapshot.data!.reference.collection('friends').doc(friendsId[index]);
                return StreamBuilder(
                    stream: friendRef.snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && !snapshot.hasError) {
                        final friendData = snapshot.data!.data();
                        if(friendData != null && friendData is Map<String, dynamic>) {
                          return FriendsListTile(
                            friendId: friendData['uid'],
                            firstname: friendData['firstname'],
                            lastname: friendData['lastname'],
                            availabilityState: friendData['availabilityState'],
                          );
                        }else{
                          return const Center(child: Text('friend_notfound'));
                        }
                      }else{
                        return Center(child: Text('friend_notfound'.tr));
                      }
                    }
                );
              });
        }
        else {
          return Center( child: Text('friend_notfound'.tr));
        }
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
          return ListView.builder(
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
          );
        }
      },
    );
  }

  accept(String friendId) async {
    await FirestoreUser(userId: currentUserId).acceptFriendRequest(friendId);
    if(mounted){
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

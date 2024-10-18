
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../services/user_services.dart';
import '../../utils/show_custom_snackbar.dart';

/*class FriendController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = Get.find<UserServices>();
  RxBool isLoading = false.obs;
  RxBool isInitialized = false.obs;
  RxString friendShipStatus = "".obs;
  var friendList = [].obs;
  var friendRequests = [].obs;
  RxList<Map<String, dynamic>> searchedUsersList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        getFriendRequests(user.uid);
        getFriendList(user.uid);
      }
    });

    isLoading.value = false;
    isInitialized.value = true;
  }


  Future<void> getFriendRequests(String userId) async {
    isLoading.value = true;
    try {
      final querySnapshot = await UserServices(userId: userId).getFriendRequests();
      if (querySnapshot.docs.isNotEmpty) {
        friendRequests.assignAll(querySnapshot.docs.map((doc) => doc.data()));
      } else {
        friendRequests.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching friends: $e");
      }
    }
    isLoading.value = false;
  }



  Future<void> getFriendList(String userId) async {
    isLoading.value = true;
    try {
      final querySnapshot = await UserServices(userId: userId).getFriendList();
      if (querySnapshot.docs.isNotEmpty) {
        friendList.assignAll(querySnapshot.docs.map((doc) => doc.data()));
      } else {
        friendList.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching friends: $e");
      }
    }
    isLoading.value = false;
  }

  Future<void> searchUserByName(String username) async {
    try {
      isLoading.value = true;
      searchedUsersList.value = [];

      var querySnapshot = await userServices.searchByUserName(username);
      var searchResults = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      for (var user in searchResults) {
        String searchedUserId = user['uid'];

        // Check if the user is a friend or in friendRequest
        bool isFriend = friendList.any((friend) => friend['uid'] == searchedUserId);
        bool hasReceivedRequest = friendRequests.any((request) => request['uid'] == searchedUserId);

        // Assign friendship or request status based on the conditions
        user['friendStatus'] = isFriend
            ? "TheyAreFriends"
            : hasReceivedRequest
            ? "WaitingAnswer"
            : "NoRequest";

        searchedUsersList.add(user);
      }

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept(String friendId) async {
    final result = await UserServices(userId: firebaseAuth.currentUser!.uid).acceptFriendRequest(friendId);
    if(result){
      friendRequests.removeWhere((friend) => friend['uid'] == friendId);
      getFriendList(firebaseAuth.currentUser!.uid);
      showCustomSnackbar("approved_friend_request".tr, true);
    }
    else{
      showCustomSnackbar("declined_friend_request".tr, false);
    }
  }

  Future<void> decline(String friendId) async {
    final result = await UserServices(userId: firebaseAuth.currentUser!.uid).declineFriendRequests(friendId);
    if(result){
      friendRequests.removeWhere((friend) => friend['uid'] == friendId);
      showCustomSnackbar("declined_friend_request".tr, true);
    }
    else{
      showCustomSnackbar("unexpected_result".tr, true);
    }
  }

}*/
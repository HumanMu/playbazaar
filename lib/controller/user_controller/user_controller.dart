import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/services/user_services.dart';
import '../../models/friend_model.dart';
import '../../models/user_model.dart';
import '../../utils/show_custom_snackbar.dart';

class UserController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = Get.find<UserServices>();

  RxBool isLoading = false.obs;
  RxBool isInitialized = false.obs;
  RxString friendShipStatus = "".obs;
  var friendList = [].obs;
  var recievedFriendRequests = [].obs;
  var sentFriendRequests = [].obs;

  Rxn<UserModel> userData = Rxn<UserModel>();
  RxList<Map<String, dynamic>> searchedUsersList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        listenToUserChanges(user.uid);
        listenToFriendRequests();
        listenToSentRequests();
        getFriendList(user.uid);
      } else {
        clearUser();
      }
    });

    isLoading.value = false;
    isInitialized.value = true;
  }

  void listenToUserChanges(String userId) {
    userData.bindStream(userServices.getUserById(userId));
  }
  void clearUser() {
    userData.value = null;
  }

  Future<bool> sendFriendRequest(FriendModel friend, int index) async {
    bool result = await userServices.sendFriendRequest(friend);
    return result;
  }

  void listenToFriendRequests() {
    userServices.getRecievedFriendRequests(firebaseAuth.currentUser!.uid).listen((requests) {
      recievedFriendRequests.assignAll(requests);
    });
  }

  void listenToSentRequests() {
    userServices.getSentFriendRequests(firebaseAuth.currentUser!.uid).listen((requests) {
      sentFriendRequests.assignAll(requests);
    });
    sentFriendRequests.refresh();
  }

  Future<bool> cancelFriendshipRequest(String friendId) async {
    bool result = await userServices.cancelFriendshipRequest(friendId);
    return result;
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
        bool hasReceivedRequest = recievedFriendRequests.any((request) => request.uid == searchedUserId);

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
      recievedFriendRequests.removeWhere((friend) => friend.uid == friendId);
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
      recievedFriendRequests.removeWhere((friend) => friend.uid == friendId);
      showCustomSnackbar("declined_friend_request".tr, true);
    }
    else{
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/services/user_services.dart';
import '../../models/friend_model.dart';
import '../../models/user_model.dart';
import '../../services/private_message_service.dart';
import '../../utils/show_custom_snackbar.dart';

class UserController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = Get.find<UserServices>();
  final PrivateMessageService messageController = Get.find<PrivateMessageService>();
  late String currentUserId;

  RxBool isLoading = false.obs;
  RxBool isInitialized = false.obs;
  RxString friendShipStatus = "".obs;
  //var friendList = [].obs;
  //var recievedFriendRequests = [].obs;
  //var sentFriendRequests = [].obs;
  RxList<FriendModel> friendList = <FriendModel>[].obs;
  RxList<FriendModel> receivedFriendRequests = <FriendModel>[].obs;
  RxList<FriendModel> sentFriendRequests = <FriendModel>[].obs;

  Rxn<UserModel> userData = Rxn<UserModel>();
  RxList<Map<String, dynamic>> searchedUsersList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;

    firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        currentUserId = firebaseAuth.currentUser!.uid;
        listenToUserChanges(user.uid);
        listenToFriendRequests();
        listenToSentRequests();
        getFriendList(user.uid);
        //Get.put(NotificationController());


        /*userServices.listenToFriendList(user.uid);
        userServices.listenToReceivedFriendRequests(user.uid);
        userServices.listenToSentFriendRequests(user.uid);*/
      } else {
        clearUser();
      }
      isLoading.value = false;
      isInitialized.value = true;
    });



  }

  void clearUser() {
    userData.value = null;
  }

  void listenToUserChanges(String userId) {
    userData.bindStream(userServices.getUserById(userId));
  }

  /*List<FriendModel> get friendList => userServices.friendList;
  List<FriendModel> get receivedFriendRequests => userServices.receivedFriendRequests;
  List<FriendModel> get sentFriendRequests => userServices.sentFriendRequests;
    */

  void listenToFriendRequests() {
    userServices.getRecievedFriendRequests(firebaseAuth.currentUser!.uid).listen((requests) {
      receivedFriendRequests.assignAll(requests);
    });
  }

  void listenToSentRequests() {
    userServices.getSentFriendRequests(firebaseAuth.currentUser!.uid).listen((requests) {
      sentFriendRequests.assignAll(requests);
    });
    sentFriendRequests.refresh();
  }

  Future<void> getFriendList(String userId) async {
    isLoading.value = true;
    try {
      final querySnapshot = await UserServices(userId: userId).getFriendList();
      if (querySnapshot.docs.isNotEmpty) {
        friendList.assignAll(querySnapshot.docs.map((doc) => FriendModel.fromFirestore(doc)).toList());
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
        bool isFriend = friendList.any((friend) => friend.uid == searchedUserId);
        bool hasReceivedRequest = receivedFriendRequests.any((request) => request.uid == searchedUserId);


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

  Future<bool> sendFriendRequest(FriendModel friend, int index) async {
    bool result = await userServices.sendFriendRequest(friend);
    return result;
  }

  Future<bool> cancelFriendshipRequest(String friendId) async {
    return await userServices.cancelFriendshipRequest(friendId);
  }

  Future<bool> removeFriendById(String friendId) async {
    bool removeResult = await userServices.removeFriendById(friendId);
    if(removeResult){
      friendList.removeWhere((friend) => friend.uid ==friendId);
    }
    return removeResult;
  }


  Future<void> accept(String friendId) async {
    try {
      final chatId = await messageController.createChat(currentUserId, friendId);

      if (chatId == null) {
        showCustomSnackbar("chat_creation_failed".tr, false);
        return;
      }

      final result = await UserServices().acceptFriendRequest(chatId, friendId);
      if (result != null) {
        friendList.add(result);
        showCustomSnackbar("approved_friend_request".tr, true);
      } else {
        showCustomSnackbar("failed_to_accept_friend_request".tr, false);
      }

    } catch (e) {
      showCustomSnackbar("declined_friend_request".tr, false);
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }


  Future<void> decline(String friendId) async {
    final result = await UserServices(userId: currentUserId).declineFriendRequests(friendId);
    if(result){
      showCustomSnackbar("declined_friend_request".tr, true);
    }
    else{
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  Future<FriendModel?> getASingleFriendById(String friendId) async {
    try{
      final friendResult = await userServices.getASingleFriendById(currentUserId, friendId);
      return friendResult;
    }catch(e){
      return null;
    }
  }
}

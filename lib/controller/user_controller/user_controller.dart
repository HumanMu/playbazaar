import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/enums.dart';
import 'package:playbazaar/functions/enum_converter.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/user_services.dart';
import '../../models/DTO/recent_interacted_user_dto.dart';
import '../../models/friend_model.dart';
import '../../models/friend_request_result_action.dart';
import '../../models/user_model.dart';
import '../../services/private_message_service.dart';
import '../../global_widgets/show_custom_snackbar.dart';

class UserController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = Get.find<UserServices>();
  final HiveUserService _hiveUserService = Get.find();
  final PrivateMessageService messageController = Get.find<PrivateMessageService>();
  final RxList<FriendModel> friendRequests = <FriendModel>[].obs;
  Rxn<UserModel> userData = Rxn<UserModel>();
  RxList<Map<String, dynamic>> searchedUsersList = <Map<String, dynamic>>[].obs;
  RxList<FriendModel> searchedFriends = <FriendModel>[].obs;
  RxList<FriendRequestResultModel> friendshipListner = <FriendRequestResultModel>[].obs;
  StreamSubscription? _friendsSubscription;
  final RxBool isLoading = false.obs;
  RxBool isInitialized = false.obs;
  late String currentUserId;


  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;

    firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        currentUserId = firebaseAuth.currentUser!.uid;
        listenToUserChanges(user.uid);
        _initFriendsListener(user.uid);
        _updateFriendInLocalStorage(user.uid);
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


  void _initFriendsListener(String userId) {
    _friendsSubscription?.cancel();
    _friendsSubscription = userServices
        .listenToFriends(userId)
        .listen((friends) {
        friendRequests.assignAll(friends);
        },
        onError: (error) {
          if (kDebugMode) {
            print("Error fetching friends listner");
          }
        }
    );
  }

 /* RxList<FriendModel> searchLocalFriends(String query) {
    if (query.isEmpty) return RxList<FriendModel>();

    return RxList<FriendModel>(
        _hiveUserService.getRecentUsers()
            .where((user) =>
            user.fullname.toLowerCase().contains(query.toLowerCase())
        )
          .map(recentFriend2FriendModel)
          .toList()
    );
  }

  void searchFriends(String query, {bool localOnly = false}) {
    // First, always search locally in Hive
    searchedFriends.value = searchLocalFriends(query);

    // Only search Firestore if not local-only mode and search icon is clicked
    if (!localOnly && query.isNotEmpty) {
      searchInFirestore(query);
    }
  }*/

  Future<bool> searchInFirestore(String friendName) async {
    isLoading.value = true;
    List<FriendModel> foundedFriends = await userServices.searchByFriendsName(currentUserId, friendName);

    if (foundedFriends.isNotEmpty) {
      final existingHiveUsers = _hiveUserService.getRecentUsers().map((user) => user.uid).toSet();
      for (var friend in foundedFriends) {
        if (!existingHiveUsers.contains(friend.uid)) {
          searchedFriends.add(friend);
        }
      }
      searchedFriends.clear();
      searchedFriends.addAll(foundedFriends);
      isLoading.value = false;
      return true;
    }
    else{
      isLoading.value = false;
      return false;
    }
  }

  Future<void> _updateFriendInLocalStorage(String uid) async {
    userServices.listenToFriendRequestsResult(uid).listen((friendshipsResult) async {
      if (friendshipsResult.isEmpty) {
        return;
      }
      else {
        for (var friendResult in friendshipsResult) {
          if (friendResult.friendshipStatus == FriendshipStatus.unfriended) {
            _hiveUserService.deleteRecentUser(friendResult.uid);
          }
          else if(friendResult.friendshipStatus == FriendshipStatus.accepted){
            await userServices.deleteFriendRequestResult(uid, friendResult.uid);
            FriendModel? friendModel = await userServices.getASingleFriendById(currentUserId, friendResult.uid);
            if(friendModel?.friendshipStatus == FriendshipStatus.good) {
              RecentInteractedUserDto recentUser = RecentInteractedUserDto(
                uid: friendModel!.uid,
                fullname: friendModel.fullname,
                avatarImage: friendModel.avatarImage,
                lastMessage: 'say_hi',
                timestamp: Timestamp.now(),
                friendshipStatus: friendShipState2String(FriendshipStatus.good),
                chatId: friendModel.chatId,
              );
              _hiveUserService.addOrUpdateRecentUser(recentUser);
            }
          }
        }
      }
    });
  }



  /*Future<void> getFriendList(String userId) async {
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
  }*/



  Future<bool> sendFriendRequest(FriendModel friend, int index) async {
    bool result = await userServices.sendFriendRequest(friend);
    return result;
  }

  Future<void> cancelFriendRequest(String friendId) async {
    bool cancelResult = await userServices.cancelFriendshipRequest(friendId);
    if(cancelResult){
      _hiveUserService.deleteRecentUser(friendId);
    }
  }

  Future<void> acceptFriendRequest(String friendId) async {
    try {
      final chatId = await messageController.createChat(currentUserId, friendId);

      if (chatId == null) {
        showCustomSnackbar("chat_creation_failed".tr, false);
        return;
      }

      final recentUser = await UserServices().acceptFriendRequest(chatId, friendId);
      if (recentUser != null) {
        _hiveUserService.addOrUpdateRecentUser(recentUser);
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


  Future<void> declineFriendRequest(String friendId) async {
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


  Future<bool> removeFriendById(String friendId) async {
    try {
      bool removeResult = await userServices.removeFriendById(friendId);
      if (removeResult) {
        await _hiveUserService.deleteRecentUser(friendId);
      }
      return removeResult;
    } catch (e) {
      return false;
    }
  }


  Future<void> searchGlobalByUserName(String username) async {
    try {
      isLoading.value = true;
      searchedUsersList.value = [];

      var querySnapshot = await userServices.searchByUserName(username);
      var searchResults = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      for (var user in searchResults) {
        searchedUsersList.add(user);
      }
    } finally {
      isLoading.value = false;
    }
  }



}

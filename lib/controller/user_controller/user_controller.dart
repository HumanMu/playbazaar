import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:playbazaar/services/user_services.dart';

class UserController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = Get.put(UserServices());

  RxBool isLoading = false.obs;
  var friendList = [].obs;


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


}

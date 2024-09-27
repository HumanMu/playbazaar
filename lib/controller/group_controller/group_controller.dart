import 'dart:async';
import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/membership_toggler_model.dart';
import '../../services/group_services.dart';
import '../../utils/show_custom_snackbar.dart';

class GroupController extends GetxController {
  late final GroupServices groupsServices;
  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    groupsServices = Get.put(GroupServices());
  }



  Future<void> createNewGroup(String userName, String adminId, String groupName, String? groupPassword) async {
    try {
      isLoading.value = true;
      await GroupServices(userId: adminId).createGroup(userName, adminId, groupName, groupPassword);
      await GroupServices(userId: adminId).getGroupsList();

      showCustomSnackbar("group_created".tr, true);
    } catch (e) {
      showCustomSnackbar("unexpected_result".tr, false);
    } finally {
      isLoading.value = false;
    }
  }

  Future toggleGroupMembership(MembershipTogglerModel toggle, userId) async {
    await GroupServices(userId: userId).toggleGroupMembership(toggle);
  }

  Future <bool> checkIfUserJoined(MembershipTogglerModel toggle) async {
    return await GroupServices().checkIfUserJoined(toggle);
  }


}
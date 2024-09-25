import 'dart:async';
import 'package:get/get.dart';
import '../../services/group_services.dart';
import '../../utils/show_custom_snackbar.dart';

class GroupController extends GetxController {
  late final GroupsServices groupsServices;
  var isLoading = false.obs;



  @override
  void onInit() {
    super.onInit();
    groupsServices = Get.put(GroupsServices());
  }



  Future<void> createNewGroup(String userName, String adminId, String groupName, String? groupPassword) async {
    try {
      isLoading.value = true;
      await GroupsServices(userId: adminId).createGroup(userName, adminId, groupName, groupPassword);
      await GroupsServices(userId: adminId).getGroupsList();

      showCustomSnackbar("group_created".tr, true);
    } catch (e) {
      showCustomSnackbar("unexpected_result".tr, false);
    } finally {
      isLoading.value = false;
    }
  }


}
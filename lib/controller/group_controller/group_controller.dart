import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/models/DTO/add_group_member.dart';
import '../../models/DTO/add_user_to_group_dto.dart';
import '../../models/DTO/create_group_dto.dart';
import '../../services/group_services.dart';
import '../../utils/show_custom_snackbar.dart';

class GroupController extends GetxController {
  final UserController userController = Get.find<UserController>();
  String userId = "";
  late final GroupServices groupsServices;
  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    groupsServices = Get.put(GroupServices());
    userId =  userController.firebaseAuth.currentUser!.uid;
  }


  Future<DocumentSnapshot> getGroupById(String groupId) async {
    String splittedGroupId = splitByUnderscore(groupId)[0];
    return await GroupServices(userId: userId).getGroupsById(splittedGroupId);
  }



  Future<void> createNewGroup(CreateGroupDto newGroup, AddUserToGroupDto creator) async {
    try {
      isLoading.value = true;
      await GroupServices().createGroup(newGroup, creator);
      showCustomSnackbar("group_created".tr, true);
    } catch (e) {
      showCustomSnackbar("unexpected_result".tr, false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addGroupMember(AddGroupMemberDto addGroup) async {
    final resultCode = await GroupServices(userId: userId).addGroupMember(addGroup);
      resultCode
          ? showCustomSnackbar("group_membership_succed".tr, true)
          : showCustomSnackbar("group_membership_failed".tr, false);

      return resultCode;
  }

  Future<bool> removeGroupFromUser(AddGroupMemberDto toggle, userId) async {
    final resultCode = await GroupServices(userId: userId).removeGroupFromUser(toggle);
    resultCode
        ? showCustomSnackbar("leaving_group_succed".tr, true)
        : showCustomSnackbar("leaving_group_failed".tr, false);

    return resultCode;
  }

  bool checkIfUserIsMemberOfGroup(String groupId)  {
    final myGroupList = userController.userData.value?.groupsId;
    if(myGroupList !=null && myGroupList.isNotEmpty ){
      if(myGroupList.contains(groupId)){
        return true;
      }
      else{
        return false;
      }
    }
    else{
      return false;
    }
  }


}
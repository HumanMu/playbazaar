import 'package:get/get.dart';
import '../../services/group_services.dart';

class GroupInfoController extends GetxController {
  final GroupServices groupServices = Get.put(GroupServices());

  var isLoading = false.obs;
  var groupMembers = [].obs;




  /*void getMember(String groupId) async {
    isLoading.value = true;
    Stream memberStream = groupServices.getGroupMember(groupId);

    memberStream.listen((snapshot) {
      if (snapshot.exists) {
        groupMembers.assignAll(snapshot.data()?['members'] ?? []);
      }
    });

    isLoading.value = false;
  }*/


}

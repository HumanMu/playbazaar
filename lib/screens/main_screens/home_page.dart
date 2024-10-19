import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/add_user_to_group_dto.dart';
import 'package:playbazaar/models/DTO/create_group_dto.dart';
import 'package:playbazaar/screens/widgets/dialogs/accept_result_dialog.dart';
import '../../api/Authentication/auth_service.dart';
import '../../constants/constants.dart';
import '../../controller/group_controller/group_controller.dart';
import '../../controller/user_controller/user_controller.dart';
import '../../functions/string_cases.dart';
import '../../helper/encryption/encrypt_string.dart';
import '../../utils/notfound.dart';
import '../../utils/text_boxes/text_box_decoration.dart';
import '../widgets/tiles/custom_group_tile.dart';
import '../widgets/sidebar_drawer.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final userController = Get.find<UserController>();
  final groupNameController = TextEditingController();
  final groupPasswordController = TextEditingController();
  final _popUpDialogController = ValueNotifier<bool>(false);
  String groupName = "";
  String? groupPassword = "";
  late bool privateToggler = false;
  String userName = "";


  @override
  void dispose() {
    _popUpDialogController.dispose();
    groupNameController.dispose();
    groupPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if(userController.isLoading.value){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/search', arguments: {'searchId': 'group'});
            },
            icon: const Icon(Icons.search, color: Colors.white,),
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          "my_memberships".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      drawer: SidebarDrawer(
        authService: authService,
        parentContext: context,
      ),

      body: groupList(),

      floatingActionButton: FloatingActionButton(
        onPressed: () { popUpDialog(context); },
        elevation: 0,
        backgroundColor: Colors.green,
        child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40
        ),
      ),
    );
  }

  Widget groupList() {
    return Obx(() {
      final groupsId = userController.userData.value?.groupsId;

      if (groupsId == null || groupsId.isEmpty) {
        return Center(
          child: notFound("not_found_title".tr, "not_found_message".tr),
        );
      }

      return ListView.builder(
        itemCount: groupsId.length,
        itemBuilder: (context, index) {
          final groupId = groupsId[index];
          final groupInfo = splitByUnderscore(groupId);
          return CustomGroupTile(
            groupId: splitByUnderscore(groupId)[0],
            groupName: groupInfo.length > 1 ? groupInfo[1].trim() : '',
            admin: splitByUnderscore(groupId)[1],
            isPublic: groupInfo[2]=='true'? true : false,
          );
        },
      );
    });
  }


  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            _popUpDialogController.addListener(() {
                setState(() {
                  privateToggler = _popUpDialogController.value;
                });
            });

            return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("creating_group_title".tr,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    Text("creating_group_description".tr),
                    userController.isLoading.value == true
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Colors.red,
                          ))
                        : TextField(
                            controller: groupNameController,
                            onChanged: (val) {
                              groupName = val;
                            },
                            decoration: decoration("group_name_hint".tr),
                          ),
                    privatePublicToggler(_popUpDialogController),
                    Visibility(
                      visible: privateToggler,
                      child: TextField(
                        controller: groupPasswordController,
                        obscureText: true,
                        onChanged: (val) {
                          groupPassword = val;
                        },
                        decoration: decoration("group_password_hint".tr),
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      groupPasswordController.text = "";
                      groupNameController.text = "";
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("btn_cancel".tr),
                  ),
                  ElevatedButton(
                    onPressed: () => createGroup(),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("btn_create".tr),
                  ),
                ]);
          }));
        });
  }

  privatePublicToggler(controller) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: AdvancedSwitch(
        controller: controller,
        enabled: true,
        height: 35,
        width: 100,
        borderRadius: const BorderRadius.all(Radius.circular(120)),
        inactiveColor: Colors.green,
        activeColor: Colors.red,
        inactiveChild: Text('private'.tr),
        activeChild: Text('public'.tr),
        thumb: ValueListenableBuilder<bool>(
            valueListenable: controller,
            builder: (context, value, child) {
              return Icon(
                controller.value
                    ? Icons.security_outlined
                    : Icons.public_outlined,
                size: 30,
              );
            }),
      ),
    );
  }


  void createGroup() async {
    String encryptedPassword = "";

    if (groupNameController.text.trim().isEmpty || groupNameController.text.trim().length > 25) {
      acceptResultDialog(context, "", "group_names_valid_size".tr);
      return;
    }

    if (groupNameController.text.trim().contains("_")) {
      acceptResultDialog(context, "", "group_name_unvalid_characters".tr);
      return;
    }

    if (privateToggler) {
      if (groupPasswordController.text.trim().length < 4) {
        acceptResultDialog(context, "", "private_group_is_selected".tr);
        return;
      }

      encryptedPassword = await EncryptionHelper.encryptPassword(groupPasswordController.text);
    }
    CreateGroupDto newGroup = CreateGroupDto(
      creatorId: FirebaseAuth.instance.currentUser!.uid,
      groupName: groupName,
      avatarImage: "",
      isPublic: !privateToggler,
      groupPassword: encryptedPassword,
    );

    AddUserToGroupDto creator = AddUserToGroupDto(
      userName: userName,
      avatarImage: FirebaseAuth.instance.currentUser?.photoURL ?? "",
      userRole: GroupUserRole.isCreator,
    );
    await GroupController().createNewGroup(newGroup, creator);

    popDialog();
  }




  void popDialog() {
    groupPasswordController.text = "";
    groupNameController.text = "";
    privateToggler = false;
    Navigator.of(context).pop();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../controller/user_controller/auth_controller.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';
import 'avatars/primary_avatar.dart';
import 'tiles/list_tile.dart';

class SidebarDrawer extends StatefulWidget {
  final BuildContext parentContext;
  final AuthService authService;

  const SidebarDrawer({
    super.key,
    required this.authService,
    required this.parentContext,
  });

  @override
  SidebarDrawerState createState() => SidebarDrawerState();
}

class SidebarDrawerState extends State<SidebarDrawer> {
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  AuthController authController = Get.put(AuthController());
  late int friendRequestLength = 0;
  String userName = "";

  @override
  void initState() {
    super.initState();
    getFriendRequestsLength();
  }

  getUserData() async {
    final value = await SharedPreferencesManager.getString(
        SharedPreferencesKeys.userNameKey);
    if (value != null && value != "") {
      setState(() {
        userName = value;
      });
    } else {
      userName = "";
    }
  }

  void navigateTo(String path) {
    Get.toNamed('/$path');
  }

  void logoutAction() async {
    await authController.logOutUser();
    if (!mounted) return;
    Get.offAllNamed('/login');
  }

  getFriendRequestsLength() async {
    friendRequestLength =
        await FirestoreUser(userId: currentUserId).getFriendRequestsLength();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.red,
            alignment: const Alignment(0, 0),
            child: Column(
              children: [
                const SizedBox(height: 25),
                const PrimaryAvatarImage(editing: false),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              ListTileWidget(
                iconColor: Colors.red,
                title: "my_friends".tr,
                icon: Icons.group,
                length: friendRequestLength,
                hasFriends: true,
                action: ()=> navigateTo('friendsList'),
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "my_page".tr,
                icon: Icons.home,
                action: () => navigateTo('profile'),
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "my_chat".tr,
                icon: Icons.mark_unread_chat_alt,
                action: () => navigateTo('home'),
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "games".tr,
                icon: Icons.games_sharp,
                action: () => navigateTo('mainQuiz'),
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "logout".tr,
                icon: Icons.logout,
                action: logoutAction,
              ),
              const Divider(
                color: Colors.grey, // Line color
                thickness: 1, // Line thickness
                indent: 20, // Left padding
                endIndent: 20, // Right padding
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "settings".tr,
                icon: Icons.settings,
                action: () => navigateTo('settings'),
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "policy_title".tr,
                icon: Icons.policy_outlined,
                action: () => navigateTo('policy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

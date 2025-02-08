import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../controller/user_controller/auth_controller.dart';
import '../../services/hive_services/hive_user_service.dart';
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
  final String? currentUser = FirebaseAuth.instance.currentUser!.uid;
  final recentUsersService = Get.find<HiveUserService>();
  AuthController authController = Get.put(AuthController());


  void navigateTo(String path) {
    Get.toNamed('/$path');
  }

  void logoutAction() async {
    await authController.logOutUser();
    await recentUsersService.clearRecentUsers();
    if (!mounted) return;
    Get.offAllNamed('/login');
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 250,
      child:  SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.red,
                alignment: Alignment(0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    const PrimaryAvatarImage(editing: false),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "my_friends".tr,
                    icon: Icons.group,
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
                    title: "groups".tr,
                    icon: Icons.mark_unread_chat_alt,
                    action: () => navigateTo('home'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "games".tr,
                    icon: Icons.games_sharp,
                    action: () => navigateTo('mainGames'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "logout".tr,
                    icon: Icons.logout,
                    action: logoutAction,
                  ),
                  const Divider(
                    color: Colors.redAccent,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
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
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/config/routes/static_app_routes.dart';
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
    context.push('/$path');
    Navigator.of(context).pop();
  }

  void logoutAction() async {
    await authController.logOutUser();
    await recentUsersService.clearRecentUsers();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.65,
      child:  SingleChildScrollView(
        child: Container(
          color: Colors.white54,
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
                    boldTitle: true,
                    icon: Icons.group,
                    action: ()=> navigateTo('friendsList'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "my_page".tr,
                    boldTitle: true,
                    icon: Icons.home,
                    action: () => navigateTo('profile'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "groups".tr,
                    boldTitle: true,
                    icon: Icons.mark_unread_chat_alt,
                    action: () => navigateTo('home'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "games".tr,
                    boldTitle: true,
                    icon: Icons.games_sharp,
                    action: () => navigateTo('mainGames'),
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
                    boldTitle: true,
                    icon: Icons.settings,
                    action: () => navigateTo('settings'),
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "policy_title".tr,
                    boldTitle: true,
                    icon: Icons.policy_outlined,
                    action: () => navigateTo('policy'),
                  ),
                  const Divider(
                    color: Colors.redAccent,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTileWidget(
                    iconColor: Colors.red,
                    title: "logout".tr,
                    boldTitle: true,
                    icon: Icons.logout,
                    action: logoutAction,
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

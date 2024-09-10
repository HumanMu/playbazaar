import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../games/games/quiz/main_quiz_page.dart';
import '../../helper/sharedpreferences.dart';
import '../main_screens/home_page.dart';
import '../main_screens/login_pages.dart';
import '../main_screens/profile_page.dart';
import '../secondary_screens/policy.dart';
import '../secondary_screens/recieved_requests.dart';
import 'avatars/primary_avatar.dart';
import 'list_tile.dart';

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
  //AuthService authService = AuthService();
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

  void navigateToFriends() {
    Navigator.pushReplacement(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => const RecievedRequests()),
    );
  }

  void navigateToProfile() {
    Navigator.pushReplacement(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void navigateToChatPage() {
    Navigator.pushReplacement(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void navigateToGames() {
    Navigator.pushReplacement(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => const QuizMainPage()),
    );
  }

  void navigateToPolicy() {
    Navigator.pushReplacement(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => const Policy()),
    );
  }

  void logoutAction() async {
    await widget.authService.logOutUser();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) =>
          false, // This removes all the previous routes to prevent users from go back to previous route after logout
    );
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
                action: navigateToFriends,
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "my_page".tr,
                icon: Icons.home,
                action: navigateToProfile,
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "my_chat".tr,
                icon: Icons.mark_unread_chat_alt,
                action: navigateToChatPage,
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "games".tr,
                icon: Icons.games_sharp,
                action: navigateToGames,
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "logout".tr,
                icon: Icons.logout,
                action: logoutAction,
              ),
              const Divider(
                // This draws a horizontal line between widgets
                color: Colors.grey, // Line color
                thickness: 1, // Line thickness
                indent: 20, // Left padding
                endIndent: 20, // Right padding
              ),
              ListTileWidget(
                iconColor: Colors.red,
                title: "policy_title".tr,
                icon: Icons.policy_outlined,
                action: navigateToPolicy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

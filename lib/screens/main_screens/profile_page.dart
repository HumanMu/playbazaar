import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import '../widgets/avatars/primary_avatar.dart';
import '../widgets/email_verification_page.dart';
import '../widgets/header.dart';
import 'package:provider/provider.dart';
import '../widgets/text_boxes/text_inputs.dart';
import 'edit_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  AuthService authService = AuthService();
  bool isSignedIn = false;
  bool isEmailVerified = false;



  @override
  void initState() {
    super.initState();
    getUserLoggedInState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData();
  }



  void fetchData() async {
    final firestoreUser = Provider.of<FirestoreUser>(context, listen: false);
    String? email = authService.firebaseAuth.currentUser?.email;
    if (email != null) {
      await firestoreUser.getUserByEmail(email);
      isEmailVerified = firestoreUser.isEmailVerified;
    }
  }

  getUserLoggedInState() async {
    bool? val = await SharedPreferencesManager.getBool(SharedPreferencesKeys.userLoggedInKey);
    if (val != null) {
      setState(() {
        isSignedIn = val;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<FirestoreUser>(
        builder: (context, fireUser, child) {
          if (fireUser.multiUser.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: ClipPath(
                            clipper: Header(),
                            child: Container(
                              color: Colors.limeAccent,
                              height: 205,
                            ),
                          ),
                        ),
                        ClipPath(
                          clipper: Header(),
                          child: Container(
                            color: Colors.redAccent,
                            height: 185,
                            alignment: Alignment.centerLeft,
                            child: const PrimaryAvatarImage(editing: false),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(!isEmailVerified) const EmailVerificationCountdown(),
                        Container(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              CustomLanguage().languageDialog(context);
                            },
                            child: Text('language'.tr, style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                        Text(
                          'aboutme'.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 45),
                        ),
                        Column(
                          children: [
                            CustomTextInputs(
                              description: "name".tr,
                              value: "${fireUser.multiUser[0].firstname} ${fireUser.multiUser[0].lastname}",
                              edit: false,
                            ),
                            CustomTextInputs(
                              description: "email".tr,
                              value: fireUser.multiUser[0].email,
                              edit: false,
                            ),
                            CustomTextInputs(
                              description: "points".tr,
                              value: fireUser.multiUser[0].userPoints.toString(),
                              edit: false,
                            ),
                            CustomTextInputs(
                              description: "me".tr,
                              value: fireUser.multiUser[0].aboutme ?? "",
                              edit: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _editPage(),
                              const SizedBox(width: 5),
                              _goToChatRoom(),
                            ],
                          ),
                        ), // Edit and chatpage buttons
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _editPage() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final resultColor = states.contains(WidgetState.pressed) ? Colors.redAccent : Colors.lime[800];
          return resultColor;
        }),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditPage()),
        );
      },
      child: Text('btn_edit'.tr),
    );
  }

  Widget _goToChatRoom() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final resultColor = states.contains(WidgetState.pressed) ? Colors.redAccent : Colors.lime[800];
          return resultColor;
        }),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      child: Text('btn_chat_groups'.tr),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/models/user_model.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import 'package:provider/provider.dart';
import '../../utils/headerstack.dart';
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
  late UserProfileModel userProfileModel;
  bool isLoading = true;


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


  getUserLoggedInState() async {
    bool? val = await SharedPreferencesManager.getBool(SharedPreferencesKeys.userLoggedInKey);
    if (val != null) {
      setState(() {
        isSignedIn = val;
      });
      fetchData();
    }
    else{
      navigateToLogin();
    }
  }



  void fetchData() async {
    if(isSignedIn) {
      final email = await SharedPreferencesManager.getString(SharedPreferencesKeys.userEmailKey);
      final firstname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey);
      final lastname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userLastNameKey);
      final aboutme = await SharedPreferencesManager.getString(SharedPreferencesKeys.userAboutMeKey);
      final userPoint = await SharedPreferencesManager.getInt(SharedPreferencesKeys.userPointKey) ?? 0;
      fetchDataFromFirestore();

      if(email != null) {
        setState(() {
          userProfileModel = UserProfileModel(
              email: email,
              firstName: firstname,
              lastName: lastname,
              aboutMe: aboutme,
              userPoint: userPoint
          );
          isLoading = false;
        });
      }
      else{
        fetchDataFromFirestore();
      }
    }
    else{
      fetchDataFromFirestore();
    }
  }

  void checkEmailVerification() async {
    final email = authService.firebaseAuth.currentUser?.email;
    if (email != null) {
      isEmailVerified = authService.firebaseAuth.currentUser!.emailVerified;
      setState(() {
        // Trigger UI rebuild to show/hide EmailVerificationCountdown
      });
      if (!isEmailVerified) {
        // Optionally, you could send a verification email here if needed
      }
    }
  }

  fetchDataFromFirestore() async {
    final firestoreUser = Provider.of<FirestoreUser>(context, listen: false);
    String? email = authService.firebaseAuth.currentUser?.email;
    if (email != null) {
      await firestoreUser.getUserByEmail(email);

      setState(() {
        isEmailVerified = firestoreUser.isEmailVerified;
        isLoading = false;
      });
    }
  }

  navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage())
    );
  }



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeaderStack(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          value: "${userProfileModel.firstName} ${userProfileModel.lastName}",
                          edit: false,
                        ),
                        CustomTextInputs(
                          description: "email".tr,
                          value: userProfileModel.email,
                          edit: false,
                        ),
                        CustomTextInputs(
                          description: "points".tr,
                          value: userProfileModel.userPoint.toString(),
                          edit: false,
                        ),
                        CustomTextInputs(
                          description: "me".tr,
                          value: userProfileModel.aboutMe ?? "",
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
      child: Text('btn_chats'.tr),
    );
  }
}


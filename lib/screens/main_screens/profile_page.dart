import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/models/user_model.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/text_boxes/text_inputs.dart';

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
      Get.offNamed('/home');
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



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          "my_page".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25
          ),
        ),
      ),
      drawer: SidebarDrawer(
        authService: authService,
        parentContext: context,
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/playbazaar_profile.png',
                  height: 250,
                  width: 250,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          CustomLanguage().languageDialog(context);
                        },
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('language'.tr,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.red),
                          ],
                        ),
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
                      child: _editPage(),
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
    return SizedBox(
      width: double.infinity,  // Makes the button take the full width of the screen
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            final resultColor = states.contains(WidgetState.pressed) ? Colors.redAccent : Colors.green;
            return resultColor;
          }),
        ),
        onPressed: () {
          Get.toNamed('/edit');
        },
        child: Text('btn_edit'.tr),
      ),
    );
  }


  /*Widget _goToChatRoom() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final resultColor = states.contains(WidgetState.pressed) ? Colors.redAccent : Colors.green;
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
  }*/
}


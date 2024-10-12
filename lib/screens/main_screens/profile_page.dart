import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../controller/user_controller/user_controller.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/text_boxes/text_inputs.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final userController = Get.find<UserController>();
  AuthService authService = AuthService();
  bool isSignedIn = false;
  bool isEmailVerified = false;
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    getUserLoggedInState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  getUserLoggedInState() async {
    bool? val = await SharedPreferencesManager.getBool(SharedPreferencesKeys.userLoggedInKey);
    if (user != null) {
      setState(() {
        isSignedIn = true;
        isLoading = false;
      });
    }
    else{
      Get.offNamed('/login');
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
      body:
      Obx(() {
        if(userController.isLoading.value){
          return Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/playbazaar_caffe.png',
                    height: 300,
                    width: 300,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              value: user?.displayName ??"" //userProfileModel.fullname ??"",
                          ),
                          CustomTextInputs(
                              description: "email".tr,
                              value: user?.email ??"" //userProfileModel.email,
                          ),
                          CustomTextInputs(
                              description: "points".tr,
                              value: userController.userData.value?.userPoints.toString() ?? "0"
                          ),
                          CustomTextInputs(
                              description: "me".tr,
                              value: userController.userData.value?.aboutme ??""
                          )
                        ],
                      ),
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
        );
      }),
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

}

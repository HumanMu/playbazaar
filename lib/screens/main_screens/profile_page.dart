import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/string_cases.dart';
import '../../admob/ad_manager_services.dart';
import '../../api/Authentication/auth_service.dart';
import '../../controller/user_controller/user_controller.dart';
import '../../services/hive_services/hive_user_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/text_boxes/text_inputs.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final userController = Get.find<UserController>();
  final recentUsersService = Get.find<HiveUserService>();
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
    if (user != null) {
      setState(() {
        isSignedIn = true;
        isLoading = false;
      });
      await recentUsersService.init();
      await AdManagerService().initialize(); // Admob
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
        iconTheme: IconThemeData(color: Colors.white),
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
                      Text(
                        'aboutme'.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 45),
                      ),
                      Column(
                        children: [
                          CustomTextInputs(
                              description: "name".tr,
                              value: capitalizeFullname(user?.displayName ?? ""),
                          ),
                          CustomTextInputs(
                              description: "email".tr,
                              value: user?.email ??""
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
                      SizedBox(height: 30),
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
        child: Text('btn_edit'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

}

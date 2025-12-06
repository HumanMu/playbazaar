import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/config/routes/static_app_routes.dart';
import 'package:playbazaar/functions/string_cases.dart';
import '../../api/Authentication/auth_service.dart';
import '../../controller/user_controller/user_controller.dart';
import '../../global_widgets/rarely_used/update_info_dialog.dart';
import '../../services/app_update/version_manager_service.dart';
import '../../services/hive_services/hive_user_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/text_boxes/text_inputs.dart';


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends ConsumerState<ProfilePage> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewVersion();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _checkForNewVersion() {
    // Get singleton instance (already initialized)
    final versionManager = VersionManagerService();

    if (versionManager.hasNewVersion()) {
      debugPrint('✅ New version detected - showing dialog');

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => UpdateInfoDialog(
          version: versionManager.getCurrentVersion(),
          onClose: () {
            versionManager.markVersionAsSeen();
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      debugPrint('❌ No new version detected');
    }
  }


  void getUserLoggedInState() async {
    if (user != null) {
      setState(() {
        isSignedIn = true;
        isLoading = false;
      });
      await recentUsersService.init();
    }
    else{
      context.go(AppRoutes.login);
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
      body: SafeArea(
        bottom: true,
        top: false,
        child: Obx(() {
          if(userController.isLoading.value){
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset('assets/images/playbazaar_caffe.png',
                        height: 300,
                        width: 300,
                      ),
                      /*ElevatedButton(
                        onPressed: _showTestDialog,
                        child: Text('Test: Show Debug Info'),
                      ),
                      ElevatedButton(
                        onPressed: _simulateUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text('Test: Simulate Update'),
                      ),*/
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
                    ],
                  ),
                ),
              ),
              // Fixed button at bottom
              Container(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                width: double.infinity,
                child: _editPage(),
              ),
            ],
          );
        }),
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
        onPressed: ()=> context.push(AppRoutes.edit),
        child: Text('btn_edit'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showTestDialog() {
    final vm = VersionManagerService();
    debugPrint(vm.getDebugInfo());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Version Debug Info'),
        content: Text(vm.getDebugInfo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateUpdate() async {
    final vm = VersionManagerService();

    debugPrint('=== BEFORE CLEAR ===');
    debugPrint(vm.getDebugInfo());

    await vm.clearLastSeenVersion();

    debugPrint('=== AFTER CLEAR ===');
    debugPrint(vm.getDebugInfo());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Version cleared! Hot restart app to see dialog'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Restart',
            textColor: Colors.white,
            onPressed: () {
              // User needs to manually restart
            },
          ),
        ),
      );
    }
  }


}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/controller/user_controller/auth_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../api/Authentication/auth_service.dart';
import '../../models/DTO/user_profile_dto.dart';
import '../widgets/text_boxes/text_inputs.dart';



class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPage();
}

class _EditPage extends State<EditPage> {
  final UserController userController = Get.find<UserController>();
  AuthService authService = AuthService();
  late UserProfileModel userProfileModel;
  late TextEditingController fullnameCon;
  late TextEditingController aboutCon;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() {
      userProfileModel = UserProfileModel(
          email: userController.userData.value!.email,
          fullname: authService.firebaseAuth.currentUser?.displayName,
          aboutMe: userController.userData.value?.aboutme,
          userPoint: userController.userData.value?.userPoints,
      );

      fullnameCon = TextEditingController(text: userProfileModel.fullname);
      aboutCon = TextEditingController(text: userProfileModel.aboutMe);

      isLoading = false;
    });
  }

  @override
  void dispose() {
    fullnameCon.dispose();
    aboutCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/images/playbazaar_caffe.png',
                      height: 300,
                      width: 300,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'aboutme'.tr,
                            style: const TextStyle(color: Colors.black, fontSize: 45),
                          ),
                          Form(
                            autovalidateMode: AutovalidateMode.always,
                            onChanged: () {
                              setState(() {
                                Form.of(primaryFocus!.context!).save();
                              });
                            },
                            child: Column(
                              children: [
                                CustomTextFormField(controller: fullnameCon, labelText: 'name'.tr),
                                CustomTextFormField(controller: aboutCon, maxLine: 6, labelText: 'aboutme'.tr),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fixed save button at bottom
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              height: 50,
              child: _saveButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          backgroundColor:
          WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.redAccent;
            } else {
              return Colors.green;
            }
          }),
        ),
        onPressed: () {
          saveUserData();
        },
        child: Text('btn_save'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }


  Future<void> saveUserData() async {
    int messageLength = aboutCon.text.length;
    if(messageLength > 300){
      showCustomSnackbar(
          "${"current_message_length".tr}: $messageLength "
          "${"allowed_message_length_300".tr}", false, timing: 6
      );
      return;
    }
    if(
      fullnameCon.text.trim() != userProfileModel.fullname?.trim()
      || aboutCon.text.trim() != userProfileModel.aboutMe?.trim()
    ) {
      UserProfileModel editedData = UserProfileModel(
        email: userProfileModel.email,
        fullname: fullnameCon.text.trim().toLowerCase(),
        aboutMe: aboutCon.text.trim(),
      );
      bool result = await AuthController().editUserAuthentication(editedData);//await FirestoreUser().editUserData(editedData);
      if(result) {
        try {
          final user = FirebaseAuth.instance.currentUser!;
          await user.updateProfile(
            displayName: fullnameCon.text.trim(),
            photoURL: "",
          );
          showCustomSnackbar('your_changes_succed'.tr, true);

        } catch (e) {
          showCustomSnackbar('unexpected_result'.tr, false);
          return;
        }
      }
      else{
        showCustomSnackbar('unexpected_result'.tr, false);
      }       
    }
    else{
      showCustomSnackbar('didnt_made_changes'.tr, false);
    }
    Get.offNamed('/profile');
  }
}

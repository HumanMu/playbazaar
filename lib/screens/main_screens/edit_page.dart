import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/api/firestore/firestore_user.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../api/Authentication/auth_service.dart';
import '../../helper/sharedpreferences.dart';
import '../../models/user_model.dart';
import '../widgets/text_boxes/text_inputs.dart';



class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPage();
}

class _EditPage extends State<EditPage> {
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
    final email = await SharedPreferencesManager.getString(SharedPreferencesKeys.userEmailKey) ?? "";
    //final firstname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey) ?? "";
    //final lastname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userLastNameKey) ?? "";
    final aboutme = await SharedPreferencesManager.getString(SharedPreferencesKeys.userAboutMeKey) ?? "";
    final userPoint = await SharedPreferencesManager.getInt(SharedPreferencesKeys.userPointKey) ?? 0;

    setState(() {
      userProfileModel = UserProfileModel(
          email: email,
          fullname: authService.firebaseAuth.currentUser?.displayName,
          aboutMe: aboutme,
          userPoint: userPoint
      );

      // Initialize the TextEditingControllers with user data
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
          : _profileInformation(context),
    );
  }

  Widget _profileInformation(context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Image.asset('assets/images/playbazaar_caffe.png',
                  height: 300,
                  width: 300,
                ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:Column(
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
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        height: 50,
                        child: _saveButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ],
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
          child: Text('btn_save'.tr),
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
      bool result = await FirestoreUser().editUserData(editedData);
      if(result) {
        try {
          final user = FirebaseAuth.instance.currentUser!;
          await user.updateProfile(
            displayName: fullnameCon.text.trim(),
            photoURL: "",
          );
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, fullnameCon.text.trim());
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userAboutMeKey, aboutCon.text.trim());
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

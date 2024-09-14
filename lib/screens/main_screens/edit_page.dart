import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/api/firestore/firestore_user.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import '../../models/user_model.dart';
import '../widgets/avatars/primary_avatar.dart';
import '../widgets/header.dart';
import '../widgets/text_boxes/text_inputs.dart';



class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPage();
}

class _EditPage extends State<EditPage> {
  late UserProfileModel userProfileModel;
  late TextEditingController firstnameCon;
  late TextEditingController lastnameCon;
  late TextEditingController aboutCon;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final email = await SharedPreferencesManager.getString(SharedPreferencesKeys.userEmailKey) ?? "";
    final firstname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userNameKey) ?? "";
    final lastname = await SharedPreferencesManager.getString(SharedPreferencesKeys.userLastNameKey) ?? "";
    final aboutme = await SharedPreferencesManager.getString(SharedPreferencesKeys.userAboutMeKey) ?? "";
    final userPoint = await SharedPreferencesManager.getInt(SharedPreferencesKeys.userPointKey) ?? 0;

    setState(() {
      userProfileModel = UserProfileModel(
          email: email,
          firstName: firstname,
          lastName: lastname,
          aboutMe: aboutme,
          userPoint: userPoint
      );

      // Initialize the TextEditingControllers with user data
      firstnameCon = TextEditingController(text: userProfileModel.firstName);
      lastnameCon = TextEditingController(text: userProfileModel.lastName);
      aboutCon = TextEditingController(text: userProfileModel.aboutMe);

      isLoading = false;
    });
  }

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    firstnameCon.dispose();
    lastnameCon.dispose();
    aboutCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                  Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        CustomLanguage().languageDialog(context);
                      },
                      child: Text(
                        'language'.tr,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  Text(
                    'aboutme'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 45),
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
                        CustomTextFormField(controller: firstnameCon, labelText: 'name'.tr),
                        CustomTextFormField(controller: lastnameCon, labelText: 'lastname'.tr),
                        CustomTextFormField(controller: aboutCon, labelText: 'aboutme'.tr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    height: 50,
                    child: SizedBox(
                      width: 80,
                      height: 40,
                      child: _saveButton(),
                    ),
                  ), // Save button
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        backgroundColor:
        WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.redAccent;
          } else {
            return Colors.lime[800];
          }
        }),
      ),
      onPressed: () {
        saveUserData();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
      },
      child: Text('btn_save'.tr),
    );
  }

  Future<void> saveUserData() async {
    if(
      firstnameCon.text.trim() != userProfileModel.firstName?.trim() 
      || lastnameCon.text.trim() != userProfileModel.lastName?.trim()
      || aboutCon.text.trim() != userProfileModel.aboutMe?.trim()
    ) {
      UserProfileModel editedData = UserProfileModel(
        email: userProfileModel.email,
        firstName: firstnameCon.text.trim(),
        lastName: lastnameCon.text.trim(),
        aboutMe: aboutCon.text.trim(),
      );
      bool result = await FirestoreUser().editUserData(editedData);
      if(result) {
        await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, firstnameCon.text.trim());
        await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, lastnameCon.text.trim());
        await SharedPreferencesManager.setString(SharedPreferencesKeys.userAboutMeKey, aboutCon.text.trim());
        showCustomSnackbar('your_changes_succed'.tr, true);
      }
      else{
        showCustomSnackbar('not_expected_result'.tr, false);
      }       
    }
    else{
      showCustomSnackbar('didnt_made_changes'.tr, false);
    }

 
  }
}

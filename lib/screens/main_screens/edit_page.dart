import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/api/firestore/firestore_user.dart';
import 'package:playbazaar/utils/show_custom_snackbar.dart';
import '../../helper/sharedpreferences.dart';
import '../../models/user_model.dart';
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
    firstnameCon.dispose();
    lastnameCon.dispose();
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
        automaticallyImplyLeading: false,
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
                Image.asset('assets/images/playbazaar_profile.png',
                  height: 250,
                  width: 250,
                ),
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
                        child: _saveButton(),
                      ), // Save button
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
        showCustomSnackbar('unexpected_result'.tr, false);
      }       
    }
    else{
      showCustomSnackbar('didnt_made_changes'.tr, false);
    }

    Get.offNamed('/profile');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/Firestore/firestore_groups.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import '../../utils/headerstack.dart';
import '../../utils/show_custom_snackbar.dart';
import '../widgets/text_boxes/text_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  String name = "";
  String email = "";
  String password = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(color: Colors.red))
          : CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const HeaderStack(),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "email".tr,
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color:  Colors.lightGreen,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.lightGreen),
                                    onChanged: (val) {
                                      setState(() {
                                          email = val;
                                        }
                                      );
                                    } ,
                                    validator: (val) {
                                      bool isValid = EmailValidator.validate(email);
                                      return isValid ? null : "not_valid_email".tr;
                                    },

                                  ),
                                  const SizedBox(height: 10,),
                                  TextFormField(
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "password".tr,
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color:  Colors.lightGreen,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.amberAccent),
                                      onChanged: (val) {
                                        setState(() {
                                          password = val;
                                        }
                                      );
                                    } ,

                                  ),
                                  const SizedBox(height: 15),
                                  _submitButton(),
                                  const SizedBox(height: 15),
                                  Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () { CustomLanguage().languageDialog(context); },
                                        child: Text('language'.tr, style: const TextStyle(color: Colors.red)),
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: RichText(
                          text: TextSpan(
                              text: "not_have_account".tr,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                    text: 'make_account_here'.tr,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer() ..onTap = () {
                                      Get.offNamed('/register');
                                      /*navigateAndReplaceScreen(context,
                                          const RegisterPage()
                                      );*/ //_navigateAndReplaceCurrentScreen(context, const RegisterPage());
                                    }),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
        ),
    );
  }


  loginUser() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await authService.loginUserWithEmailAndPassword(email, password);

        if (result) {
          final email = FirebaseAuth.instance.currentUser!.email.toString();
          QuerySnapshot snapshot = await FirestoreGroups(userId: FirebaseAuth.instance.currentUser!.uid).getUserByEmail(email);
          await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, email);
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, snapshot.docs[0]['firstname']);
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, snapshot.docs[0]['lastname']);
          await SharedPreferencesManager.setString(SharedPreferencesKeys.userRoleKey,snapshot.docs[0]['role']);
          await SharedPreferencesManager.setDouble(SharedPreferencesKeys.userPointKey,snapshot.docs[0]['userpoints']);

          Get.offNamed('/profile');

        } else {
          showCustomSnackbar("not_expected_result".tr, false);
          return;
        }
      } catch (e) {
        showCustomSnackbar('not_expected_result'.tr, false);
        return;
      } finally {
          setState(() {
            _isLoading = false;
          });
      }
    }
  }



  Widget _submitButton() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lime[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
        ),
      ),
      child: ElevatedButton(
        onPressed: loginUser, 
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          )),
          backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState>states) {
              if(states.contains(WidgetState.pressed)) {
                return Colors.redAccent;
              }else {
                return Colors.lime[800];
              }
            }
          )),
          child: Text('btn_login'.tr,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
        ),
    );
  }
}




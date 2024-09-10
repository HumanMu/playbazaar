import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../helper/sharedpreferences.dart';
import '../../shared/show_custom_snackbar.dart';
import '../widgets/avatars/primary_avatar.dart';
import '../widgets/header.dart';
import '../widgets/text_boxes/text_widgets.dart';
import 'login_pages.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  bool isLoading = false;
  String firstname = "";
  String lastname = "";
  String email = "";
  String password = "";
  String password2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,

              // slivers: [
              //   SliverFillRemaining(
              //     hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
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
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "app_name".tr,
                            style: const TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    labelText: "name".tr,
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  style:
                                      const TextStyle(color: Colors.lightGreen),
                                  onChanged: (val) {
                                    setState(() {
                                      firstname = val;
                                    });
                                  },
                                  validator: (val) {
                                    if (val!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "name_is_required".tr;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    labelText: "lastname".tr + "optional".tr,
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  style:
                                  const TextStyle(color: Colors.lightGreen),
                                  onChanged: (val) {
                                    setState(() {
                                      lastname = val;
                                    });
                                  },
                                ),

                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    labelText: "email".tr,
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  style:
                                      const TextStyle(color: Colors.lightGreen),
                                  onChanged: (val) {
                                    setState(() {
                                      email = val;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: textInputDecoration.copyWith(
                                    labelText: "password".tr,
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  style:
                                      const TextStyle(color: Colors.lightGreen),
                                  onChanged: (val) {
                                    setState(() {
                                      password = val;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: textInputDecoration.copyWith(
                                    labelText: "re_password".tr,
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  style:
                                      const TextStyle(color: Colors.lightGreen),
                                  onChanged: (val) {
                                    setState(() {
                                      password2 = val;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                _submitButton(),
                              ],
                            )),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "do_have_account".tr,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                            text: 'login_from_here'.tr,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => const LoginPage(),
                                ));
                              }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      //   ],
      // ),
    );
  }

   bool _verifyRegistrationInfo () {
     final bool isValid = EmailValidator.validate(email);
     if(!isValid) {
       showCustomSnackbar('invalid_email_format'.tr, false);
       return false;
     }
     else if(password != password2 ) {
        showCustomSnackbar('different_password'.tr, false);
     return false;
     }
     else {
       return true;
     }
   }

  _registerUser() async {
    bool verificationResult = _verifyRegistrationInfo();
    if (verificationResult) {
      if (formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });

        try {
          bool result = await authService.registerUserWithEmailAndPassword(
              firstname, lastname, email, password
          );

          if (result) {
            await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
            await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, firstname);
            await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, lastname);
            await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, email);

            if (mounted) {
              navigateAndReplaceScreen(context, const LoginPage());
              showCustomSnackbar("registration_succed".tr, true);
            } else {
              showCustomSnackbar('not_expected_result'.tr, false);
            }
          } else {
            showCustomSnackbar('not_expected_result'.tr, false);
          }
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          showCustomSnackbar('error_occurred'.tr, false);
        } finally {
            setState(() {
              isLoading = false;
            });
        }
      }
    } else {
      showCustomSnackbar('not_expected_result'.tr, false);
    }
  }

  Widget _submitButton() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lime[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: ElevatedButton(
        onPressed: _registerUser,
        style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )),
            backgroundColor:
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.redAccent;
              } else {
                return Colors.lime[800];
              }
            })),
        child: Text(
          'btn_create'.tr,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

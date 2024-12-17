import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../controller/user_controller/account_controller.dart';
import '../../global_widgets/headerstack.dart';
import '../../global_widgets/show_custom_snackbar.dart';
import '../widgets/text_boxes/text_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final AccountController accountController = Get.put(AccountController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  String firstname = "";
  String lastname = "";
  String email = "";
  String password = "";
  String password2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return accountController.isLoading.value ? const Center(
          child: CircularProgressIndicator(color: Colors.red),
        )
            : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const HeaderStack(),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 600, // Maximum width of the textfields
                    ),
                    child: Container(
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
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "name".tr,
                                      prefixIcon: const Icon(
                                        Icons.person,
                                      ),
                                    ),
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
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "lastname".tr + "optional".tr,
                                      prefixIcon: const Icon(
                                        Icons.person,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        lastname = val;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "email".tr,
                                      prefixIcon: const Icon(
                                        Icons.email,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        email = val.toLowerCase();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "password".tr,
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        password = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                      labelText: "re_password".tr,
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        password2 = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _submitButton(),
                                ],
                              )),
                        ],
                      ),
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
                                Get.offNamed('/login');
                              }),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      )
    );
  }


  Widget _submitButton(){
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lime[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: ElevatedButton(
        onPressed: () async {
          bool result = await _verifyRegistrationInfo();
          if (result ) {
            String fullname = "$firstname $lastname";
            await accountController.registerUser(
                fullname,
                email,
                password
            );
          }
          else {
            return;
          }
        },
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
          style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Future<bool> _verifyRegistrationInfo () async {
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user_controller/auth_controller.dart';
import '../../utils/show_custom_snackbar.dart';

class ResetPasswordPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

  ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reset_password'.tr),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr,
                hintText: 'enter_your_email'.tr,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  authController.sendPasswordResetEmail(emailController.text);
                } else {
                  showCustomSnackbar('not_valid_email'.tr, false);
                }
              },
              child: Text('send_reset_link'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

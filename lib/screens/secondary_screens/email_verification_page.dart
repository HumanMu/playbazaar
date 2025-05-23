import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/global_widgets/dialog/accept_dialog.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../controller/user_controller/auth_controller.dart';
import '../../services/push_notification_service/device_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerificationPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final authController = Get.find<AuthController>();

  bool canResend = false;
  Timer? resendTimer;
  Timer? emailCheckTimer;
  int resendCooldown = 30;

  @override
  void initState() {
    super.initState();
    startVerificationCheck();
    startResendCooldown();
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    emailCheckTimer?.cancel();
    super.dispose();
  }

  void startVerificationCheck() {
    emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await authController.checkAndUpdateEmailVerificationStatus();
      if (authController.isEmailVerified.value) {
        timer.cancel(); // Stop the timer once email is verified
        await askForNotificationPermission();
        await DeviceService().registerDevice();
        Get.offAllNamed('/profile');
      }
    });
  }

  Future<void> askForNotificationPermission()async {
    acceptDialog(context, "notifications".tr, "notification_permission_description".tr);
  }

  void startResendCooldown() {
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        resendCooldown--;
        if (resendCooldown <= 0) {
          canResend = true;
          resendTimer?.cancel(); // Stop cooldown timer after 30 seconds
        }
      });
    });
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        canResend = false;
        resendCooldown = 30; // Reset cooldown for resend button
      });
      showCustomSnackbar('verification_email_sent'.tr, true);
    } catch (e) {
      showCustomSnackbar('unexpected_result'.tr, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("verify_email_title".tr, style: TextStyle(fontSize: 30)),
                Text('email_verification_intro'.tr),
                Text('signed_as'.tr),
                Text(FirebaseAuth.instance.currentUser!.email.toString()),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: canResend ? sendEmailVerification : null,
                  child: Text(canResend ? 'btn_resent'.tr : '${'btn_resent'.tr} ($resendCooldown)'),
                ),
                const SizedBox(height: 10),
                Text('check_your_inbox'.tr),
                const SizedBox(height: 30),
                const Divider(),
                Text("reassign_text".tr),
                TextButton(
                  child: Text('btn_restart'.tr),
                  onPressed: () {
                    resendTimer?.cancel();
                    emailCheckTimer?.cancel();
                    Get.offAllNamed('/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


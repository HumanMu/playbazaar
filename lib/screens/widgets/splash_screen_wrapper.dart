import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/controller/user_controller/auth_controller.dart';
import 'package:playbazaar/screens/secondary_screens/animated_splash_screen.dart';

class SplashScreenWrapper extends StatelessWidget {
  const SplashScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final nextScreen = determineNextScreen();

    return AnimatedSplashScreen(
      imagePath: 'assets/icons/splash_screen_960x960.png',
      nextScreen: nextScreen,
      duration: const Duration(milliseconds: 2500),
    );
  }

  Widget determineNextScreen() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isSignedIn.value) {
        return const ProfilePage();
      } else {
        return const LoginPage();
      }
    } catch (e) {
      return const LoginPage();
    }
  }
}

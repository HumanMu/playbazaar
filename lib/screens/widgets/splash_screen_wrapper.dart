import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/controller/user_controller/auth_controller.dart';
import 'package:playbazaar/screens/secondary_screens/animated_splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:playbazaar/admob/ad_manager_services.dart';
import 'package:playbazaar/controller/message_controller/private_message_controller.dart';
import 'package:playbazaar/controller/user_controller/account_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/helper/encryption/secure_key_storage.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/push_notification_service/push_notification_service.dart';
import 'package:playbazaar/services/user_services.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Run all the initialization that was in main()
      final notificationService = NotificationService();
      await notificationService.init();

      await dotenv.load(fileName: "assets/config/.env");
      SecureKeyStorage secureStorage = SecureKeyStorage();
      String key = dotenv.env['AES_KEY'] ?? '';
      String iv = dotenv.env['AES_IV'] ?? '';
      await secureStorage.storeKeys(key, iv);

      await Hive.initFlutter();
      Get.put(HiveUserService(), permanent: true);
      await AdManagerService().initialize();
      Get.put(UserServices(), permanent: true);
      Get.put(PrivateMessageController(), permanent: true);
      Get.put(UserController(), permanent: true);
      Get.put(AuthController(), permanent: true);
      Get.put(AccountController(), permanent: true);

      // Initialization complete
      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/splash_screen_960x960.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 30),
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              SizedBox(height: 20),
              Text(
                'Fejl under indlæsning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _retryInitialization,
                child: Text('Prøv igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      // Show loading screen while initializing
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/splash_screen_960x960.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Indlæser Play Bazaar...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Initialization complete - show your animated splash screen
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


/*class SplashScreenWrapper extends StatelessWidget {
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
}*/

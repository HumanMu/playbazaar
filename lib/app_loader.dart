import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:playbazaar/admob/ad_manager_services.dart';
import 'package:playbazaar/controller/message_controller/private_message_controller.dart';
import 'package:playbazaar/controller/user_controller/account_controller.dart';
import 'package:playbazaar/controller/user_controller/auth_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/helper/encryption/secure_key_storage.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/push_notification_service/push_notification_service.dart';
import 'package:playbazaar/services/user_services.dart';
import 'package:playbazaar/config/routes/app_routes.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _status = 'Starter app...';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _status = 'Indlæser notifikationer...');
      await Future.delayed(Duration(milliseconds: 200)); // Let UI update

      final notificationService = NotificationService();
      await notificationService.init();

      setState(() => _status = 'Indlæser konfiguration...');
      await Future.delayed(Duration(milliseconds: 200));

      await dotenv.load(fileName: "assets/config/.env");

      setState(() => _status = 'Opsætter sikkerhed...');
      await Future.delayed(Duration(milliseconds: 200));

      SecureKeyStorage secureStorage = SecureKeyStorage();
      String key = dotenv.env['AES_KEY'] ?? '';
      String iv = dotenv.env['AES_IV'] ?? '';
      await secureStorage.storeKeys(key, iv);

      setState(() => _status = 'Initialiserer database...');
      await Future.delayed(Duration(milliseconds: 200));

      await Hive.initFlutter();

      setState(() => _status = 'Indlæser tjenester...');
      await Future.delayed(Duration(milliseconds: 200));

      // Initialize all your services that AppRoutes expects
      Get.put(HiveUserService(), permanent: true);
      await AdManagerService().initialize();
      Get.put(UserServices(), permanent: true);
      Get.put(PrivateMessageController(), permanent: true);
      Get.put(UserController(), permanent: true);
      Get.put(AuthController(), permanent: true);
      Get.put(AccountController(), permanent: true);

      setState(() => _status = 'Klart!');
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate to your AppRoutes instead of individual screens
      _navigateToAppRoutes();

    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() => _status = 'Fejl opstod - prøver igen...');
      await Future.delayed(Duration(seconds: 2));
      _initializeApp(); // Retry
    }
  }

  void _navigateToAppRoutes() {
    // Navigate to your original AppRoutes (formerly PlayBazaar)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppRoutes(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icons/splash_screen_960x960.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 30),
            Text(
              'Play Bazaar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                _status,
                key: ValueKey(_status),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
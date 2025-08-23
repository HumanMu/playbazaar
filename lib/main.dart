git import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:playbazaar/screens/widgets/splash_screen_wrapper.dart';
import 'admob/ad_manager_services.dart';
import 'app_loader.dart';
import 'config/firebase_options.dart';
import 'config/routes/app_routes.dart';
import 'controller/message_controller/private_message_controller.dart';
import 'controller/user_controller/account_controller.dart';
import 'controller/user_controller/auth_controller.dart';
import 'controller/user_controller/user_controller.dart';
import 'helper/encryption/secure_key_storage.dart';
import 'services/hive_services/hive_user_service.dart';
import 'services/push_notification_service/push_notification_service.dart';
import 'services/user_services.dart';


 Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

   // Only critical Firebase initialization
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

   // Start MobileAds without waiting
   unawaited(MobileAds.instance.initialize());

   runApp(const AppInitializer());
 }

 class AppInitializer extends StatelessWidget {
   const AppInitializer({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Play Bazaar',
       debugShowCheckedModeBanner: false,
       home: AppLoader(),
     );
   }
 }

/*Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize MobileAds
  unawaited(MobileAds.instance.initialize());


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


  runApp(
    const PlayBazaar(),
  );
}*/



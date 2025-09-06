import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_loader.dart';
import 'config/firebase_options.dart';


 Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

   unawaited(MobileAds.instance.initialize());

   runApp(const AppInitializer());
 }

 class AppInitializer extends StatelessWidget {
   const AppInitializer({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: "Play Bazaar",
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



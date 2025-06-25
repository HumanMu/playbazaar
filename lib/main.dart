import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:playbazaar/config/firebase_options.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/user_services.dart';
import 'admob/ad_manager_services.dart';
import 'config/routes/app_routes.dart';
import 'controller/message_controller/private_message_controller.dart';
import 'controller/user_controller/account_controller.dart';
import 'controller/user_controller/auth_controller.dart';
import 'controller/user_controller/user_controller.dart';
import 'helper/encryption/secure_key_storage.dart';
import 'package:playbazaar/services/push_notification_service/push_notification_service.dart';


Future<void> main() async {
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
  await AdManagerService().initialize();
  Get.put(HiveUserService(), permanent: true);
  Get.put(UserServices(), permanent: true);
  Get.put(PrivateMessageController(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(AccountController(), permanent: true);


  runApp(
    const PlayBazaar(),
  );
}



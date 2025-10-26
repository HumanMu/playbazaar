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
import 'package:playbazaar/helper/sharedpreferences/sharedpreferences.dart';

/// Handles all app initialization logic in a centralized, testable way
class AppInitializer {
  /// Callback for status updates during initialization
  final Function(String status)? onStatusUpdate;

  AppInitializer({this.onStatusUpdate});

  /// Initialize the entire app with proper error handling
  Future<void> initialize() async {
    try {
      await _loadLanguagePreferences();
      await _initializeNotifications();
      await _loadEnvironmentConfig();
      await _setupSecureStorage();
      await _initializeLocalDatabase();
      await _initializeServices();
    } catch (e, stackTrace) {
      debugPrint('❌ AppInitializer error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _loadLanguagePreferences() async {
    _updateStatus('loading_notifications');
    await Future.delayed(Duration(milliseconds: 200));
  }

  Future<void> _initializeNotifications() async {
    final notificationService = NotificationService();
    await notificationService.init();
  }

  Future<void> _loadEnvironmentConfig() async {
    _updateStatus('loading_configurations');
    await Future.delayed(Duration(milliseconds: 200));
    await dotenv.load(fileName: "assets/config/.env");
  }

  Future<void> _setupSecureStorage() async {
    _updateStatus('setting_security');
    await Future.delayed(Duration(milliseconds: 200));

    SecureKeyStorage secureStorage = SecureKeyStorage();
    String key = dotenv.env['AES_KEY'] ?? '';
    String iv = dotenv.env['AES_IV'] ?? '';
    await secureStorage.storeKeys(key, iv);
  }

  Future<void> _initializeLocalDatabase() async {
    _updateStatus('loading_your_data');
    await Future.delayed(Duration(milliseconds: 200));
    await Hive.initFlutter();
  }

  Future<void> _initializeServices() async {
    _updateStatus('loading_other_services');
    await Future.delayed(Duration(milliseconds: 200));

    // Register all GetX controllers and services
    Get.put(HiveUserService(), permanent: true);
    await AdManagerService().initialize();
    Get.put(UserServices(), permanent: true);
    Get.put(PrivateMessageController(), permanent: true);
    Get.put(UserController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(AccountController(), permanent: true);

    _updateStatus('done');
    await Future.delayed(Duration(milliseconds: 500));
  }

  void _updateStatus(String status) {
    onStatusUpdate?.call(status);
  }

  /// Get language code from preferences
  Future<String> getLanguageCode() async {
    List<String>? languageData = await SharedPreferencesManager.getStringList(
        SharedPreferencesKeys.appLanguageKey);
    return languageData?.first ?? 'en';
  }
}
/*import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static Future<void> initializeFirebase() async {
    try {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp();

      // Configure App Check with exponential backoff and retry
      await _configureAppCheck();
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  static Future<void> _configureAppCheck() async {
    int maxRetries = 3;
    int baseDelayMs = 100;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          await FirebaseAppCheck.instance.activate(
            androidProvider: AndroidProvider.debug,
            appleProvider: AppleProvider.debug,
          );
        } else {
          await FirebaseAppCheck.instance.activate(
            androidProvider: AndroidProvider.playIntegrity, // Or DeviceCheck for iOS
            appleProvider: AppleProvider.appAttest,
          );
        }
        print('App Check activated successfully'); // Add a success message
        break; // Exit the loop on success
      } catch (e, stackTrace) {
        print('App Check activation attempt ${attempt + 1} failed: $e');
        print(stackTrace); // Crucial for debugging
        if (attempt < maxRetries - 1) {
          int delayMs = baseDelayMs * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        } else {
          print('App Check activation ultimately failed. Continuing without App Check.');
        }
      }
    }
  }

  // Optional: Manually get App Check token with error handling
  static Future<String?> getAppCheckToken({bool forceRefresh = false}) async {
    try {
      return await FirebaseAppCheck.instance.getToken(forceRefresh);
    } catch (e) {
      print('Error retrieving App Check token: ');
      return null;
    }
  }
}*/
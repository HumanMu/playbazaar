import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdManagerService {
  static final AdManagerService _instance = AdManagerService._internal();
  factory AdManagerService() => _instance;
  AdManagerService._internal();

  // Configure your ad unit IDs
  static const String androidAdUnitId = 'ca-app-pub-8489114651875477/8702898430';
  static const String iosAdUnitId = 'ca-app-pub-xxxxxxxx/xxxxxxxx';


  /*void printTestDeviceID() {
    MobileAds.instance.getRequestConfiguration().then((requestConfiguration) {
      print('Test Device ID: ${requestConfiguration.testDeviceIds}');
    });
  }*/

  // Get the appropriate ad unit ID based on platform
  String get adUnitId {
    if (kDebugMode) {
      // Use test ad unit ID in debug mode
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid ? androidAdUnitId : iosAdUnitId;
  }

  // Initialize AdMob
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();

      // Optional: Configure request configuration
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Add your test device IDs
          testDeviceIds: ['F46C538DC1EAAF5DA7A53D0C32CA5F02'],
        ),
      );

      debugPrint('AdMob initialized successfully');
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }
}


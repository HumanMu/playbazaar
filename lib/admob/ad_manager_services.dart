import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_helper.dart';


class AdManagerService {
  static final AdManagerService _instance = AdManagerService._internal();
  factory AdManagerService() => _instance;
  AdManagerService._internal();


  String get adBannerUnitId {
    if (kDebugMode) return AdmobHelperDebug.bannerAdUnitId;
    return AdmobHelper.bannerAdUnitId;
  }

  String get adRewardedInterstitialUnitId {
    if (kDebugMode) return AdmobHelperDebug.rewardedInterstitialAdUnitId;
    return AdmobHelper.rewardedInterstitialAdUnitId;
  }

  Future<void> initialize() async {

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Add phisycal test device IDs
          testDeviceIds: ['F46C538DC1EAAF5DA7A53D0C32CA5F02'],
        ),
      );

    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

/*void
 printTestDeviceID() {
    MobileAds.instance.getRequestConfiguration().then((requestConfiguration) {
      print('Test Device ID: ${requestConfiguration.testDeviceIds}');
    });
  }*/

}





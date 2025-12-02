import 'dart:io';

class AdmobHelper {
  static String get bannerAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8489114651875477/8702898430';
    }
    if(Platform.isIOS){
      return 'ca-app-pub-8489114651875477/3306575173';
    }
    else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8489114651875477/8702898430';
    }
    if(Platform.isIOS){
      return 'ca-app-pub-8489114651875477/3306575173';
    }
    else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Add rewarded interstitial ad unit IDs
  static String get rewardedInterstitialAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8489114651875477/9448364199';
    }
    if(Platform.isIOS){
      return 'ca-app-pub-8489114651875477/6383217154';
    }
    else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}


class AdmobHelperDebug {
  static String get bannerAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    if(Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2435281174';
    }

    else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Add test rewarded interstitial ad unit IDs
  static String get rewardedInterstitialAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5354046379';
    }

    if(Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6978759866';
    }

    else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

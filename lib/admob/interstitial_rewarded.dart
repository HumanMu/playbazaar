import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_helper.dart';

class RewardedInterstitialAdManager {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdReady = false;
  bool get isAdReady => _isAdReady;

  Future<void> loadAd() async {
    await RewardedInterstitialAd.load(
      adUnitId: AdmobHelper.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded interstitial ad loaded successfully');
          _rewardedInterstitialAd = ad;
          _isAdReady = true;

          // Set up full screen content callback
          _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Rewarded interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Rewarded interstitial ad dismissed');
              ad.dispose();
              _rewardedInterstitialAd = null;
              _isAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Rewarded interstitial ad failed to show: $error');
              ad.dispose();
              _rewardedInterstitialAd = null;
              _isAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded interstitial ad failed to load: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  Future<void> showAd({
    required Function() onUserEarnedReward,
    required Function() onAdDismissed,
    required Function() onAdFailedToShow,
  }) async {
    if (_rewardedInterstitialAd == null) {
      debugPrint('Rewarded interstitial ad is not ready yet');
      onAdFailedToShow();
      return;
    }

    // Set up callbacks before showing
    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('✅ Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('✅ Ad dismissed full screen content');
        ad.dispose();
        _rewardedInterstitialAd = null;
        _isAdReady = false;
        // Call the callback
        onAdDismissed();
        // Reload ad for next time
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Ad failed to show: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        _isAdReady = false;
        onAdFailedToShow();
        // Reload ad for next time
        loadAd();
      },
    );

    try {
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('✅ User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
    } catch (e) {
      debugPrint('❌ Error showing ad: $e');
      onAdFailedToShow();
    }
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _isAdReady = false;
  }
}
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager_services.dart';

class AdaptiveBannerAd extends StatefulWidget {
  final void Function(bool)? onAdLoaded;

  const AdaptiveBannerAd({
    super.key,
    this.onAdLoaded,
  });

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() async {
    final adManagerService = AdManagerService();

    // Use MediaQuery.of(context) in didChangeDependencies or build method
    final adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (adSize == null) {
      debugPrint('Unable to get adaptive ad size');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adManagerService.adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Banner ad loaded successfully');

          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });

          // Notify parent widget about ad load status
          widget.onAdLoaded?.call(true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Banner ad failed to load: ${error.message}');

          // Dispose of the failed ad
          ad.dispose();

          setState(() {
            _bannerAd = null;
            _isAdLoaded = false;
          });

          // Notify parent widget about ad load failure
          widget.onAdLoaded?.call(false);
        },
        onAdOpened: (Ad ad) => debugPrint('Ad opened'),
        onAdClosed: (Ad ad) {
          debugPrint('Ad closed');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Minimal space when ad is not loaded
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
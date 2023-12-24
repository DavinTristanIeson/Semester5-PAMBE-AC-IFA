import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static BannerAd? _bannerAd;
  static bool? isBannerAdReady = false;
  static DateTime _lastInterstitialTime = DateTime(2000);

  static void init() {
    MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadBannerAd();
    isBannerAdReady = false;
  }

  static void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad as InterstitialAd?;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  static void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  static void showInterstitialAd() {
    DateTime now = DateTime.now();
    Duration difference = now.difference(_lastInterstitialTime);

    if (_interstitialAd != null && difference.inMinutes < 1) {
      return;
    }
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _loadInterstitialAd();
          _lastInterstitialTime = DateTime.now();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial Ad failed to show: $error');
        },
      );
      _interstitialAd!.show();
    }
  }

  static Widget getBannerAdWidget() {
    return _bannerAd == null ? SizedBox.shrink() : AdWidget(ad: _bannerAd!);
  }
}

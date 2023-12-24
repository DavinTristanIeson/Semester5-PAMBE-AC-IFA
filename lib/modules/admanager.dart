import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager extends StatefulWidget {
  // Test ad unit
  static const INTERSTITIAL_AD_UNIT_ID =
      "ca-app-pub-3940256099942544/1033173712";
  static const BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111";
  final Widget child;

  const AdManager({super.key, required this.child});

  @override
  State<AdManager> createState() => AdManagerState();

  static AdManagerState of(BuildContext context) {
    return context.findAncestorStateOfType<AdManagerState>()!;
  }
}

class AdManagerState extends State<AdManager> {
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  DateTime _lastInterstitialTime = DateTime.fromMillisecondsSinceEpoch(0);

  Future<InterstitialAd?> _loadInterstitialAd() async {
    final completer = Completer<InterstitialAd>();
    InterstitialAd.load(
      adUnitId: AdManager.INTERSTITIAL_AD_UNIT_ID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _lastInterstitialTime = DateTime.now();
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          completer.completeError(error);
          _interstitialAd = null;
        },
      ),
    );
    return completer.future;
  }

  Future<InterstitialAd?> loadInterstitialAd() async {
    DateTime now = DateTime.now();
    Duration difference = now.difference(_lastInterstitialTime);

    if (difference.inMinutes < 5) {
      return Future.value(null);
    }
    if (_interstitialAd == null) {
      // don't wait for ad to load to prevent janky navigation
      _loadInterstitialAd();
      return Future.value(null);
    }
    _lastInterstitialTime = now;
    final ad = _interstitialAd;
    _loadInterstitialAd();
    return ad;
  }

  (BannerAd?, Future<BannerAd?>) loadBannerAd() {
    final completer = Completer<Ad>();
    final bannerAd = BannerAd(
      adUnitId: AdManager.BANNER_AD_UNIT_ID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          completer.complete(ad);
        },
        onAdFailedToLoad: (ad, error) {
          completer.completeError(error);
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    bannerAd.load();

    return (
      _bannerAd,
      Future(() async {
        try {
          await completer.future;
          _bannerAd = bannerAd;
          return bannerAd;
        } catch (e) {
          return null;
        }
      })
    );
  }

  Widget buildBanner(BannerAd? ad) {
    const size = AdSize.banner;
    return SafeArea(
      child: SizedBox(
        width: size.width.toDouble(),
        height: size.height.toDouble(),
        child: ad == null ? const SizedBox() : AdWidget(ad: ad),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

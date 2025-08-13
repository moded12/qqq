import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdsHelper {
  // ===== Banner Ad Singleton Logic =====

  static BannerAd? _bannerAd;
  static bool _bannerLoaded = false;
  static bool _isInitializing = false;
  static bool _currentlyShowing = false;

  /// Callback to notify UI when the banner loads
  static VoidCallback? onBannerLoaded;

  /// Initialize BannerAd instance only once per app session (unless disposed).
  /// Safe to call from multiple screens; will only create once.
  static void initializeBannerAd() {
    if (_bannerLoaded || _isInitializing) return;
    _isInitializing = true;

    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8177765238464378/2290295726'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerLoaded = true;
          _isInitializing = false;
          if (onBannerLoaded != null) onBannerLoaded!();
          print('✅ BannerAd loaded ONCE (singleton)');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerLoaded = false;
          _isInitializing = false;
          if (onBannerLoaded != null) onBannerLoaded!();
          print('❌ BannerAd failed to load: $error');
        },
      ),
    );

    _bannerAd!.load();
  }

  /// Returns BannerAd if loaded and not currently showing elsewhere.
  /// Use this in your widget tree to display the ad.
  static BannerAd? get bannerAd {
    if (_bannerLoaded && !_currentlyShowing) {
      _currentlyShowing = true;
      return _bannerAd;
    }
    return null;
  }

  /// Call this when banner is removed from widget tree (e.g., on screen dispose).
  /// This allows it to be shown again in another screen.
  static void bannerNoLongerVisible() {
    _currentlyShowing = false;
  }

  /// Force dispose of BannerAd; should be called on app exit or when you want to fully re-init.
  static void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
    _currentlyShowing = false;
    _isInitializing = false;
    print('🗑️ BannerAd resources disposed');
  }

  // ===== Interstitial Ad (unchanged) =====
  static DateTime? _lastInterstitialTime;
  static InterstitialAd? interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8177765238464378/9594070677'
          : 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          print('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Failed to load interstitial ad: $error');
        },
      ),
    );
  }

  static void showInterstitialAd() {
    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!).inSeconds < 45) {
      print('⏱️ Interstitial ad ignored to avoid annoyance.');
      return;
    }
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      _lastInterstitialTime = now;
    } else {
      print('⚠️ No interstitial ad loaded.');
    }
  }

  // ===== App Open Ad (unchanged) =====
  static AppOpenAd? _appOpenAd;

  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8177765238464378/1351644457'
          : 'ca-app-pub-3940256099942544/5662855259',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          print('✅ App Open ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load App Open ad: $error');
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  static void showAppOpenAd() {
    if (_appOpenAd != null) {
      _appOpenAd!.show();
      _appOpenAd = null;
    } else {
      print('⚠️ No App Open ad loaded.');
    }
  }
}
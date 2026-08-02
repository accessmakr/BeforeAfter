import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

/// AdMob initialization and banner ad management.
/// All methods are safe to call even if AdMob is not initialized.
class AdMobService {
  static bool _initialized = false;
  static BannerAd? _bannerAd;

  /// Initializes the AdMob SDK. Call once in main().
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdMob initialized');
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  /// Returns the correct banner ad unit ID for the platform.
  static String get bannerAdUnitId {
    if (Platform.isIOS) return AdUnitIds.iosBanner;
    return AdUnitIds.androidBanner;
  }

  /// Loads a new banner ad. Dispose old one first.
  static BannerAd? loadBannerAd({
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) {
    if (!_initialized) {
      onFailed();
      return null;
    }

    _bannerAd?.dispose();
    _bannerAd = null;

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('Banner ad loaded');
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          onFailed();
        },
      ),
    );

    ad.load();
    _bannerAd = ad;
    return ad;
  }

  /// Returns the current banner ad (may be null if not loaded).
  static BannerAd? get currentBanner => _bannerAd;

  /// Disposes the banner ad to free memory.
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}

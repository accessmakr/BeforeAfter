import 'package:flutter/material.dart';

/// AdMob stub. Ads temporarily disabled to fix build.
/// Re-enable by adding google_mobile_ads to pubspec.yaml.
class AdMobService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('AdMob disabled in this build');
  }

  static String get bannerAdUnitId => '';

  static dynamic loadBannerAd({
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) {
    onFailed();
    return null;
  }

  static dynamic get currentBanner => null;

  static void dispose() {}
}

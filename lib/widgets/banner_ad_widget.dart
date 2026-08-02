import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../utils/constants.dart';

/// AdMob banner that respects safe area and adapts to screen width.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdMobService.loadBannerAd(
      onLoaded: () => setState(() => _isLoaded = true),
      onFailed: () => setState(() => _isLoaded = false),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? AppColors.bgSecondaryDark
            : AppColors.bgSecondary,
        border: Border(
          top: BorderSide(
            color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
                ? AppColors.separatorDark
                : AppColors.separator,
          ),
        ),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

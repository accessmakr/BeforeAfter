import 'package:flutter/material.dart';

/// App-wide constants: colors, spacing, durations, asset paths.
/// All colors are semantic — never use raw hex in UI code.
class AppColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFFFAFAF8);
  static const Color bgPrimaryDark = Color(0xFF0A0A0A);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgSecondaryDark = Color(0xFF1C1C1E);
  static const Color bgTertiary = Color(0xFFF2F2F0);
  static const Color bgTertiaryDark = Color(0xFF2C2C2E);
  static const Color bgElevated = Color(0xFFFFFFFF);
  static const Color bgElevatedDark = Color(0xFF3A3A3C);

  // Accents (iOS system blue)
  static const Color accent = Color(0xFF007AFF);
  static const Color accentDark = Color(0xFF0A84FF);
  static const Color accentDim = Color(0xFF0051D5);
  static const Color accentDimDark = Color(0xFF409CFF);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textInverseDark = Color(0xFF000000);

  // Borders & separators
  static const Color borderSubtle = Color(0xFFE5E5EA);
  static const Color borderSubtleDark = Color(0xFF38383A);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorDark = Color(0xFF48484A);

  // Feedback
  static const Color error = Color(0xFFFF3B30);
  static const Color errorDark = Color(0xFFFF453A);
  static const Color success = Color(0xFF34C759);
  static const Color successDark = Color(0xFF30D158);

  // Overlay
  static const Color overlay = Color(0x66000000);
  static const Color overlayDark = Color(0x99000000);

  /// Returns the correct color for the current theme.
  static Color adaptive(Color light, Color dark, BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Spacing tokens — 4px base grid.
class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Animation durations.
class AppDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
}

/// Border radii.
class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Pro limits.
class AppLimits {
  static const int freeComparisons = 3;
  static const int maxImageDimension = 8192;
  static const int maxImageBytes = 100 * 1024 * 1024; // 100MB
}

/// AdMob placement IDs (replace with your real IDs from AdMob console).
class AdUnitIds {
  // TODO: Replace with your AdMob app IDs and unit IDs.
  static const String androidAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';
  static const String iosAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';
  static const String androidBanner = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
  static const String iosBanner = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
}

/// IAP product IDs (must match App Store Connect & Google Play Console).
class IapProductIds {
  static const String proMonthly = 'com.beforeafter.pro.monthly';
  static const String proYearly = 'com.beforeafter.pro.yearly';
}

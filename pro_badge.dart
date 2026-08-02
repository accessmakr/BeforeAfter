import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Small "Pro" chip shown on premium users' UI elements.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.accentDark.withOpacity(0.2) : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isDark ? AppColors.accentDark.withOpacity(0.3) : AppColors.accent.withOpacity(0.2),
        ),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.accentDark : AppColors.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

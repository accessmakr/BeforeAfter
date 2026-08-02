import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';

/// Pro upgrade screen with subscription options.
class PaywallScreen extends StatelessWidget {
  final SubscriptionProvider provider;
  const PaywallScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Unlock Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Remove ads and create unlimited comparisons.',
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _FeatureItem(icon: Icons.block, text: 'Remove all ads'),
              _FeatureItem(icon: Icons.all_inclusive, text: 'Unlimited comparisons'),
              _FeatureItem(icon: Icons.high_quality, text: 'High-resolution export'),
              _FeatureItem(icon: Icons.cloud_download, text: 'Cloud backup & restore'),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: provider,
                builder: (context, isPro, child) {
                  if (isPro) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'You\'re already Pro!',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      ...provider.products.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => provider.purchase(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.textInverse,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                ),
                              ),
                              child: Text(
                                '${product.title} — ${product.price}',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      }),
                      TextButton(
                        onPressed: provider.restore,
                        child: const Text('Restore Purchases'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(width: AppSpacing.md),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

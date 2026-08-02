import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/comparison_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';
import 'paywall_screen.dart';

/// Settings: theme, language, storage, about, pro status.
class SettingsScreen extends StatefulWidget {
  final SubscriptionProvider subscriptionProvider;
  final ComparisonProvider comparisonProvider;

  const SettingsScreen({
    super.key,
    required this.subscriptionProvider,
    required this.comparisonProvider,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _confirmingDelete = false;

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Comparisons?'),
        content: const Text('This will permanently remove all your comparisons.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.comparisonProvider.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All comparisons deleted')),
        );
      }
    }
  }

  void _goPro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(provider: widget.subscriptionProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isPro = widget.subscriptionProvider.isPro;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Pro status card
          if (!isPro)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BeforeAfter Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Unlock unlimited comparisons and remove ads.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goPro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      child: const Text('Upgrade to Pro'),
                    ),
                  ),
                ],
              ),
            ),
          // Stats
          _SectionTitle('Storage'),
          _SettingsTile(
            icon: Icons.photo_library,
            title: 'Comparisons',
            subtitle: '${widget.comparisonProvider.value.length} saved',
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear All Data',
            subtitle: 'Delete every comparison',
            isDestructive: true,
            onTap: _clearAll,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('App'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'BeforeAfter v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'BeforeAfter',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 BeforeAfter. All rights reserved.',
              );
            },
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Love the app? Let us know!',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final textColor = isDestructive
        ? Colors.red
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.textTertiary),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: AppColors.textTertiary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      tileColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    );
  }
}

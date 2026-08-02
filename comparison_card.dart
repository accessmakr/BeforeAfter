import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/comparison_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

/// Grid tile displayed on the home screen.
class ComparisonCard extends StatelessWidget {
  final ComparisonModel comparison;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const ComparisonCard({
    super.key,
    required this.comparison,
    required this.onTap,
    required this.onDelete,
    required onShare,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = comparison.beforeThumbnail;
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumb != null)
                      Image.memory(thumb, fit: BoxFit.cover)
                    else
                      Container(
                        color: isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
                        child: Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                          size: 32,
                        ),
                      ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Row(
                        children: [
                          _IconButton(
                            icon: Icons.share,
                            onTap: () {}, // onShare handled at screen level
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _IconButton(
                            icon: Icons.close,
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comparison.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormatter.relative(comparison.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

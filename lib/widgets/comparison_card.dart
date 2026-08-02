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
  final VoidCallback? onEditTitle;

  const ComparisonCard({
    super.key,
    required this.comparison,
    required this.onTap,
    required this.onDelete,
    required this.onShare,
    this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = comparison.beforeThumbnail;
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onEditTitle,
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
                      child: _MoreMenu(
                        onShare: onShare,
                        onEditTitle: onEditTitle,
                        onDelete: onDelete,
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

class _MoreMenu extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback? onEditTitle;
  final VoidCallback onDelete;

  const _MoreMenu({
    required this.onShare,
    this.onEditTitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
      ),
      onSelected: (value) {
        switch (value) {
          case 'share': onShare(); break;
          case 'edit': onEditTitle?.call(); break;
          case 'delete': onDelete(); break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 12),
              Text('Share'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 12),
              Text('Edit Title'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

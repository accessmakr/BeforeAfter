import 'package:flutter/material.dart';
import '../models/comparison_model.dart';
import '../providers/comparison_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';
import '../widgets/comparison_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/pro_badge.dart';
import 'picker_screen.dart';
import 'slider_screen.dart';
import 'paywall_screen.dart';

/// Dashboard: comparison grid, create button, search, ads.
class HomeScreen extends StatefulWidget {
  final ComparisonProvider comparisonProvider;
  final SubscriptionProvider subscriptionProvider;

  const HomeScreen({
    super.key,
    required this.comparisonProvider,
    required this.subscriptionProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.comparisonProvider.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    widget.comparisonProvider.removeListener(_onProviderUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _createComparison() async {
    final isPro = widget.subscriptionProvider.isPro;
    final isAtLimit = widget.comparisonProvider.isAtLimit;

    if (!isPro && isAtLimit) {
      _showPaywall();
      return;
    }

    final result = await Navigator.push<ComparisonModel>(
      context,
      MaterialPageRoute(builder: (_) => const PickerScreen()),
    );

    if (result != null && mounted) {
      final success = await widget.comparisonProvider.add(result);
      if (!success && mounted) {
        _showPaywall();
      }
    }
  }

  void _showPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(provider: widget.subscriptionProvider),
      ),
    );
  }

  void _openComparison(ComparisonModel comparison) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SliderScreen(comparison: comparison),
      ),
    );
  }

  Future<void> _deleteComparison(String id) async {
    await widget.comparisonProvider.delete(id);
  }

  List<ComparisonModel> get _filteredComparisons {
    final list = widget.comparisonProvider.value;
    if (_searchQuery.isEmpty) return list;
    return list.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final comparisons = _filteredComparisons;
    final isPro = widget.subscriptionProvider.isPro;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BeforeAfter',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    if (isPro) const ProBadge(),
                  ],
                ),
              ),
            ),
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search comparisons...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  ),
                ),
              ),
            ),
            // Create button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GestureDetector(
                  onTap: _createComparison,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: const Icon(Icons.add_photo_alternate, color: Colors.white),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Comparison',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Select two photos and compare',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Grid or empty state
            if (comparisons.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: AppColors.textTertiary.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No comparisons yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tap "Create Comparison" to start',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comparison = comparisons[index];
                      return ComparisonCard(
                        comparison: comparison,
                        onTap: () => _openComparison(comparison),
                        onDelete: () => _deleteComparison(comparison.id),
                        onShare: () {},
                      );
                    },
                    childCount: comparisons.length,
                  ),
                ),
              ),
            // Bottom padding for ad banner
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
      bottomNavigationBar: !isPro ? const BannerAdWidget() : null,
    );
  }
}

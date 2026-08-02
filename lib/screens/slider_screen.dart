import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/comparison_model.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/slider_widget.dart';

/// Full-screen slider view with share and export controls.
class SliderScreen extends StatefulWidget {
  final ComparisonModel comparison;
  const SliderScreen({super.key, required this.comparison});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  final GlobalKey _sliderKey = GlobalKey();
  Uint8List? _beforeBytes;
  Uint8List? _afterBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final beforeFile = File(widget.comparison.beforePath);
      final afterFile = File(widget.comparison.afterPath);
      if (await beforeFile.exists() && await afterFile.exists()) {
        final before = await beforeFile.readAsBytes();
        final after = await afterFile.readAsBytes();
        if (mounted) {
          setState(() {
            _beforeBytes = before;
            _afterBytes = after;
            _isLoading = false;
          });
        }
      } else {
        _showError('Image files not found.');
      }
    } catch (e) {
      _showError('Failed to load images.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  Future<void> _shareOriginals() async {
    await ExportService.shareOriginals(widget.comparison);
  }

  Future<void> _exportSlider() async {
    try {
      final boundary = _sliderKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await ExportService.captureWidget(boundary);
      if (image != null) {
        await ExportService.shareImage(
          image,
          text: '${widget.comparison.title} — Before & After',
        );
      }
    } catch (e) {
      _showError('Export failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    if (_isLoading || _beforeBytes == null || _afterBytes == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          widget.comparison.title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            onPressed: _shareOriginals,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: RepaintBoundary(
                key: _sliderKey,
                child: SliderWidget(
                  beforeBytes: _beforeBytes!,
                  afterBytes: _afterBytes!,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    DateFormatter.dateTime(widget.comparison.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _exportSlider,
                      icon: const Icon(Icons.download),
                      label: const Text(
                        'Export & Share',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textInverse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

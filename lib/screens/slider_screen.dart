import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/comparison_model.dart';
import '../providers/comparison_provider.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/edit_title_dialog.dart';
import '../widgets/slider_widget.dart';

class SliderScreen extends StatefulWidget {
  final ComparisonModel comparison;
  final ComparisonProvider? comparisonProvider;

  const SliderScreen({
    super.key,
    required this.comparison,
    this.comparisonProvider,
  });

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  final GlobalKey _sliderKey = GlobalKey();
  final TransformationController _zoomController = TransformationController();
  Uint8List? _beforeBytes;
  Uint8List? _afterBytes;
  bool _isLoading = true;
  bool _isFullscreen = false;
  late ComparisonModel _comparison;

  @override
  void initState() {
    super.initState();
    _comparison = widget.comparison;
    _loadImages();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  Future<void> _loadImages() async {
    try {
      final beforeFile = File(_comparison.beforePath);
      final afterFile = File(_comparison.afterPath);
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

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _resetZoom() {
    _zoomController.value = Matrix4.identity();
  }

  Future<void> _editTitle() async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => EditTitleDialog(initialTitle: _comparison.title),
    );
    if (newTitle != null && newTitle.isNotEmpty && widget.comparisonProvider != null) {
      final updated = _comparison.copyWith(title: newTitle);
      await widget.comparisonProvider!.update(updated);
      setState(() => _comparison = updated);
    }
  }

  Future<void> _saveToGallery() async {
    try {
      final boundary = _sliderKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await ExportService.captureWidget(boundary);
      if (image != null) {
        final success = await ExportService.saveToGallery(image);
        _showSuccess(success ? 'Select your gallery app to save' : 'Failed to save');
      }
    } catch (e) {
      _showError('Save failed.');
    }
  }

  Future<void> _exportAndShare() async {
    try {
      final boundary = _sliderKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await ExportService.captureWidget(boundary);
      if (image != null) {
        await ExportService.shareImage(
          image,
          text: '${_comparison.title} — Before & After',
        );
      }
    } catch (e) {
      _showError('Export failed.');
    }
  }

  Future<void> _shareOriginals() async {
    await ExportService.shareOriginals(_comparison);
  }

  Future<void> _deleteComparison() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Comparison?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && widget.comparisonProvider != null) {
      await widget.comparisonProvider!.delete(_comparison.id);
      if (mounted) Navigator.pop(context);
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
      backgroundColor: _isFullscreen ? Colors.black : (isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary),
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _comparison.title,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.fit_screen),
                  tooltip: 'Reset zoom',
                  onPressed: _resetZoom,
                ),
                IconButton(
                  icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  tooltip: 'Fullscreen',
                  onPressed: _toggleFullscreen,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit': _editTitle(); break;
                      case 'save': _saveToGallery(); break;
                      case 'share': _shareOriginals(); break;
                      case 'export': _exportAndShare(); break;
                      case 'fullscreen': _toggleFullscreen(); break;
                      case 'delete': _deleteComparison(); break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Title')),
                    const PopupMenuItem(value: 'save', child: Text('Save to Gallery')),
                    const PopupMenuItem(value: 'share', child: Text('Share Originals')),
                    const PopupMenuItem(value: 'export', child: Text('Export & Share')),
                    const PopupMenuItem(value: 'fullscreen', child: Text('Fullscreen')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: _isFullscreen
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: RepaintBoundary(
                    key: _sliderKey,
                    child: SliderWidget(
                      beforeBytes: _beforeBytes!,
                      afterBytes: _afterBytes!,
                      transformationController: _zoomController,
                    ),
                  ),
                ),
              ),
              if (!_isFullscreen)
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
                          DateFormatter.dateTime(_comparison.createdAt),
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
                            onPressed: _exportAndShare,
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
          if (_isFullscreen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: GestureDetector(
                onTap: _toggleFullscreen,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Text(
                        'Tap to exit fullscreen',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

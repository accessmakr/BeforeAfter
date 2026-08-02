import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/comparison_model.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';

/// Two-step photo picker: select "before" photo, then "after" photo.
class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _beforeFile;
  File? _afterFile;
  Uint8List? _beforeThumb;
  Uint8List? _afterThumb;
  bool _isLoading = false;

  Future<void> _pickBefore() async {
    setState(() => _isLoading = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: AppLimits.maxImageDimension,
        maxHeight: AppLimits.maxImageDimension,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        if (bytes.length > AppLimits.maxImageBytes) {
          _showError('Image too large. Max 100MB.');
          return;
        }
        setState(() {
          _beforeFile = file;
          _beforeThumb = bytes;
        });
      }
    } catch (e) {
      _showError('Failed to load image.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAfter() async {
    setState(() => _isLoading = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: AppLimits.maxImageDimension,
        maxHeight: AppLimits.maxImageDimension,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        if (bytes.length > AppLimits.maxImageBytes) {
          _showError('Image too large. Max 100MB.');
          return;
        }
        setState(() {
          _afterFile = file;
          _afterThumb = bytes;
        });
      }
    } catch (e) {
      _showError('Failed to load image.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  void _createComparison() {
    if (_beforeFile == null || _afterFile == null) return;
    final comparison = ComparisonModel.create(
      title: 'Comparison',
      beforePath: _beforeFile!.path,
      afterPath: _afterFile!.path,
      beforeThumbnail: _beforeThumb,
      afterThumbnail: _afterThumb,
    );
    Navigator.pop(context, comparison);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Comparison',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _PhotoSlot(
                label: 'BEFORE',
                imageBytes: _beforeThumb,
                onTap: _pickBefore,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.lg),
              Icon(
                Icons.arrow_downward,
                color: AppColors.textTertiary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PhotoSlot(
                label: 'AFTER',
                imageBytes: _afterThumb,
                onTap: _pickAfter,
                isDark: isDark,
              ),
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_beforeFile != null && _afterFile != null)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _createComparison,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    child: const Text(
                      'Create Comparison',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final bool isDark;

  const _PhotoSlot({
    required this.label,
    required this.imageBytes,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtle,
          ),
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap to select $label photo',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

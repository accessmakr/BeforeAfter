import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../models/comparison_model.dart';

/// Generates shareable images from comparison views.
class ExportService {
  /// Captures a widget as a PNG image.
  /// [boundary] is obtained via GlobalKey + RepaintBoundary.
  static Future<Uint8List?> captureWidget(RenderRepaintBoundary boundary) async {
    try {
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ExportService.captureWidget error: $e');
      return null;
    }
  }

  /// Shares a captured image via native share sheet.
  static Future<void> shareImage(Uint8List imageBytes, {String? text}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/beforeafter_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'Before & After comparison',
      );
    } catch (e) {
      debugPrint('ExportService.shareImage error: $e');
    }
  }

  /// Shares the original before and after photos.
  static Future<void> shareOriginals(ComparisonModel comparison) async {
    final files = <XFile>[];
    if (File(comparison.beforePath).existsSync()) {
      files.add(XFile(comparison.beforePath));
    }
    if (File(comparison.afterPath).existsSync()) {
      files.add(XFile(comparison.afterPath));
    }
    if (files.isNotEmpty) {
      await Share.shareXFiles(
        files,
        text: 'Before & After — ${comparison.title}',
      );
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Interactive before/after photo slider.
/// Supports drag, tap-to-position, and smooth snap.
class SliderWidget extends StatefulWidget {
  final Uint8List beforeBytes;
  final Uint8List afterBytes;
  final double initialPosition;

  const SliderWidget({
    super.key,
    required this.beforeBytes,
    required this.afterBytes,
    this.initialPosition = 0.5,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _position;
  bool _isDragging = false;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  void _updatePosition(Offset localPosition) {
    final RenderBox? box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final relativeX = localPosition.dx;
    setState(() {
      _position = (relativeX / size.width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final localPos = box.globalToLocal(details.globalPosition);
            _updatePosition(localPos);
          },
          onHorizontalDragStart: (_) => setState(() => _isDragging = true),
          onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
          onTapUp: (details) {
            final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final localPos = box.globalToLocal(details.globalPosition);
            _updatePosition(localPos);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Stack(
              key: _imageKey,
              fit: StackFit.expand,
              children: [
                // After image (full background)
                Image.memory(
                  widget.afterBytes,
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                ),
                // Before image (clipped by slider position)
                ClipRect(
                  clipper: _BeforeClipper(position: _position),
                  child: Image.memory(
                    widget.beforeBytes,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  ),
                ),
                // Slider line
                Positioned(
                  left: (_position * width) - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: AppColors.accent,
                  ),
                ),
                // Slider handle
                Positioned(
                  left: (_position * width) - 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isDragging ? AppColors.accentDim : AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.compare_arrows,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Labels
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: _Label(text: 'BEFORE'),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _Label(text: 'AFTER'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BeforeClipper extends CustomClipper<Rect> {
  final double position;
  _BeforeClipper({required this.position});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_BeforeClipper old) => old.position != position;
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

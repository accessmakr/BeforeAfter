import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Interactive before/after photo slider with pinch-to-zoom.
class SliderWidget extends StatefulWidget {
  final Uint8List beforeBytes;
  final Uint8List afterBytes;
  final double initialPosition;
  final TransformationController? transformationController;

  const SliderWidget({
    super.key,
    required this.beforeBytes,
    required this.afterBytes,
    this.initialPosition = 0.5,
    this.transformationController,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _position;
  bool _isDragging = false;
  late final TransformationController _internalController;

  TransformationController get _controller =>
      widget.transformationController ?? _internalController;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _internalController = TransformationController();
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Zoomable images
            InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 4.0,
              child: SizedBox(
                width: width,
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Stack(
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
                    ],
                  ),
                ),
              ),
            ),

            // Slider overlay (viewport coordinates, not affected by zoom)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                setState(() {
                  _position = (details.localPosition.dx / width).clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
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
                  // Slider handle with its own drag
                  Positioned(
                    left: (_position * width) - 24,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _position = (details.localPosition.dx / width).clamp(0.0, 1.0);
                          });
                        },
                        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
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
          ],
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

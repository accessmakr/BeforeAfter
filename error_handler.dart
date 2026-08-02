import 'package:flutter/material.dart';

/// Global error handling setup.
/// Call [ErrorHandler.install] in main() before runApp().
class ErrorHandler {
  static void install() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // TODO: Log to Crashlytics in production.
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _ErrorWidget(details: details);
    };
  }
}

class _ErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color(0xFFFAFAF8),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF3B30)),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the app. If this persists, contact support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF3C3C43)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Attempt to recover by rebuilding.
                  WidgetsBinding.instance.attachToBuildTree(
                    RenderObjectToWidgetAdapter(
                      container: WidgetsBinding.instance.renderView,
                      child: const SizedBox.shrink(),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/iap_service.dart';

/// Manages Pro subscription state across the app.
/// Listens to IapService stream and exposes a simple boolean.
class SubscriptionProvider extends ValueNotifier<bool> {
  final IapService _iap = IapService();
  StreamSubscription<bool>? _subscription;

  SubscriptionProvider() : super(false) {
    _init();
  }

  Future<void> _init() async {
    await _iap.initialize();
    // Listen to IAP stream for purchase/restoration events.
    _subscription = _iap.isProStream.listen((isPro) {
      value = isPro;
    });
    // Set initial state.
    value = _iap.isPro;
  }

  bool get isPro => value;

  /// Initiates a purchase for the given product index.
  /// 0 = monthly, 1 = yearly (based on IapService.products order).
  Future<void> purchase(int productIndex) async {
    final products = _iap.products;
    if (productIndex < 0 || productIndex >= products.length) return;
    await _iap.purchase(products[productIndex]);
  }

  /// Restores previous purchases.
  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  /// Returns product details for the paywall UI.
  List<ProductDetails> get products => _iap.products;

  @override
  void dispose() {
    _subscription?.cancel();
    _iap.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/constants.dart';

/// StoreKit / Google Play Billing wrapper.
/// Manages Pro subscription state and purchase flow.
class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _isProController = StreamController<bool>.broadcast();
  bool _isPro = false;
  List<ProductDetails> _products = [];

  Stream<bool> get isProStream => _isProController.stream;
  bool get isPro => _isPro;
  List<ProductDetails> get products => _products;

  /// Initializes IAP, loads products, and listens for purchases.
  Future<void> initialize() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available on this device');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    await _loadProducts();
    await _restorePurchases();
  }

  /// Loads product details from App Store / Google Play.
  Future<void> _loadProducts() async {
    const Set<String> ids = {
      IapProductIds.proMonthly,
      IapProductIds.proYearly,
    };
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
  }

  /// Initiates a purchase flow.
  Future<void> purchase(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restores previous purchases (for re-installs or new devices).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _restorePurchases() async {
    // Initial restore on app launch.
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error?.message}');
          break;
        case PurchaseStatus.pending:
          debugPrint('Purchase pending');
          break;
        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled');
          break;
      }
    }
  }

  void _verifyAndDeliver(PurchaseDetails purchase) {
    // Client-side verification. For production, add server-side receipt validation.
    if (purchase.productID == IapProductIds.proMonthly ||
        purchase.productID == IapProductIds.proYearly) {
      _setProState(true);
    }
    _iap.completePurchase(purchase);
  }

  void _setProState(bool value) {
    if (_isPro != value) {
      _isPro = value;
      _isProController.add(value);
    }
  }

  /// Disposes streams.
  void dispose() {
    _subscription?.cancel();
    _isProController.close();
  }
}

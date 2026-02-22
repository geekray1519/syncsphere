import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:syncsphere/services/purchase_service.dart';

class PremiumProvider extends ChangeNotifier {
  PremiumProvider({PurchaseService? purchaseService})
    : _purchaseService = purchaseService ?? PurchaseService() {
    _purchaseService.onStateChanged = notifyListeners;
  }

  final PurchaseService _purchaseService;

  bool get isPremium => _purchaseService.isPremium;
  bool get isAvailable => _purchaseService.isAvailable;
  bool get isPurchasePending => _purchaseService.isPurchasePending;
  ProductDetails? get premiumProduct => _purchaseService.premiumProduct;
  String? get errorMessage => _purchaseService.errorMessage;

  Future<void> initialize() async {
    await _purchaseService.initialize();
  }

  Future<void> purchasePremium() async {
    await _purchaseService.purchasePremium();
  }

  Future<void> restorePurchases() async {
    await _purchaseService.restorePurchases();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}

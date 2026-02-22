import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  PurchaseService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  static const String premiumProductId = 'syncsphere_premium';
  static const String _premiumKey = 'is_premium';

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool _isAvailable = false;
  bool _isPurchasePending = false;
  ProductDetails? _premiumProduct;
  String? _errorMessage;

  void Function()? onStateChanged;

  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  bool get isPurchasePending => _isPurchasePending;
  ProductDetails? get premiumProduct => _premiumProduct;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _loadCachedPremiumStatus();

    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _setErrorMessage(error.toString());
        _setPurchasePending(false);
      },
    );

    final bool available = await _iap.isAvailable();
    _setAvailable(available);

    if (!available) {
      _setPremiumProduct(null);
      await _iap.restorePurchases();
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      <String>{premiumProductId},
    );

    ProductDetails? premiumProduct;
    for (final ProductDetails product in response.productDetails) {
      if (product.id == premiumProductId) {
        premiumProduct = product;
        break;
      }
    }
    _setPremiumProduct(premiumProduct);

    if (response.error != null) {
      _setErrorMessage(response.error!.message);
    } else if (premiumProduct == null &&
        response.notFoundIDs.contains(premiumProductId)) {
      _setErrorMessage('Premium product is currently unavailable.');
    } else {
      _setErrorMessage(null);
    }

    await _iap.restorePurchases();
  }

  Future<void> purchasePremium() async {
    final ProductDetails? product = _premiumProduct;
    if (!_isAvailable || product == null) {
      _setErrorMessage('Premium product is currently unavailable.');
      return;
    }

    _setErrorMessage(null);
    _setPurchasePending(true);

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool started = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!started) {
        _setPurchasePending(false);
        _setErrorMessage('Unable to start purchase flow. Please try again.');
      }
    } catch (error) {
      _setPurchasePending(false);
      _setErrorMessage(error.toString());
    }
  }

  Future<void> restorePurchases() async {
    _setErrorMessage(null);
    try {
      await _iap.restorePurchases();
    } catch (error) {
      _setErrorMessage(error.toString());
    }
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      try {
        switch (purchaseDetails.status) {
          case PurchaseStatus.pending:
            _setPurchasePending(true);
            break;
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            _setPurchasePending(false);
            _setErrorMessage(null);
            final bool isVerified = await _verifyPurchase(purchaseDetails);
            if (isVerified) {
              await _deliverPremium();
            } else {
              _setErrorMessage('Unable to verify premium purchase.');
            }
            break;
          case PurchaseStatus.error:
            _setPurchasePending(false);
            _setErrorMessage(
              purchaseDetails.error?.message ??
                  'Purchase failed. Please try again later.',
            );
            break;
          case PurchaseStatus.canceled:
            _setPurchasePending(false);
            break;
        }
      } finally {
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return purchaseDetails.productID == premiumProductId;
  }

  Future<void> _deliverPremium() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_premiumKey, true);

    _setPremium(true);
    _setPurchasePending(false);
    _setErrorMessage(null);
  }

  Future<void> _loadCachedPremiumStatus() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _setPremium(preferences.getBool(_premiumKey) ?? false);
  }

  void _setPremium(bool value) {
    if (_isPremium == value) {
      return;
    }
    _isPremium = value;
    _notifyStateChanged();
  }

  void _setAvailable(bool value) {
    if (_isAvailable == value) {
      return;
    }
    _isAvailable = value;
    _notifyStateChanged();
  }

  void _setPurchasePending(bool value) {
    if (_isPurchasePending == value) {
      return;
    }
    _isPurchasePending = value;
    _notifyStateChanged();
  }

  void _setPremiumProduct(ProductDetails? product) {
    if (_premiumProduct == product) {
      return;
    }
    _premiumProduct = product;
    _notifyStateChanged();
  }

  void _setErrorMessage(String? message) {
    if (_errorMessage == message) {
      return;
    }
    _errorMessage = message;
    _notifyStateChanged();
  }

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

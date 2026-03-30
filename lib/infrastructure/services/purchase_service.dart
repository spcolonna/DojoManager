import 'dart:math';
import '../../core/config/shop_config.dart';

/// Wrapper sobre RevenueCat.
/// Si ShopConfig.simulationMode == true, todas las compras se efectúan
/// sin pasar por el App Store.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  /// Resultado de una compra
  Future<PurchaseResult> purchaseProduct(String storeId) async {
    if (ShopConfig.simulationMode) {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 600));
      return PurchaseResult.success(storeId);
    }

    // TODO: integrar RevenueCat real
    // try {
    //   final result = await Purchases.purchaseProduct(storeId);
    //   return PurchaseResult.success(storeId);
    // } on PlatformException catch (e) {
    //   return PurchaseResult.error(e.message ?? 'Purchase failed');
    // }

    return PurchaseResult.error('RevenueCat not integrated yet');
  }

  Future<bool> restorePurchases() async {
    if (ShopConfig.simulationMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }
    // TODO: Purchases.restorePurchases()
    return false;
  }
}

class PurchaseResult {
  final bool success;
  final String? productId;
  final String? error;

  const PurchaseResult._({required this.success, this.productId, this.error});

  factory PurchaseResult.success(String productId) =>
      PurchaseResult._(success: true, productId: productId);

  factory PurchaseResult.error(String msg) =>
      PurchaseResult._(success: false, error: msg);
}
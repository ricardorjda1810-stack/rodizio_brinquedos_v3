import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// in_app_purchase_android 0.5.0's public queryPastPurchases path forces the
// responseCode to OK, discarding native Billing failures. Use the pinned host
// API to read the actual result on the existing connection, without replacing
// its purchase callbacks or constructing a second BillingClient.
// ignore: implementation_imports
import 'package:in_app_purchase_android/src/messages.g.dart';
// ignore: implementation_imports
import 'package:in_app_purchase_android/src/pigeon_converters.dart';

Future<List<PurchaseDetails>> queryAndroidSubscriptions(
  InAppPurchase inAppPurchase,
) async {
  if (!await inAppPurchase.isAvailable()) {
    throw StateError('Google Play Billing unavailable');
  }
  final response = await InAppPurchaseApi().queryPurchasesAsync(
    PlatformProductType.subs,
  );
  if (response.billingResult.responseCode != PlatformBillingResponse.ok) {
    throw IAPError(
      source: 'google_play',
      code: response.billingResult.responseCode.name,
      message: 'Não foi possível consultar as assinaturas no Google Play.',
    );
  }
  return response.purchases
      .expand((purchase) => GooglePlayPurchaseDetails.fromPurchase(
            purchaseWrapperFromPlatform(purchase),
          ))
      .toList();
}

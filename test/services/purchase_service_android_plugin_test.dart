import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/services/android_subscription_query.dart';

import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

// Exercise the actual pinned Flutter Android plugin and its platform addition,
// mocking only the native Billing boundary (Pigeon messages). This catches
// changes to the native response contract and real Billing error handling.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'real Android plugin queries ownership, preserves errors and pending state',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    SharedPreferences.setMockInitialValues({'premium_active': true});
    const codec = _BillingCodec();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const prefix =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.';
    var subscriptions = <_WireValue>[];
    var responseCode = 3; // PlatformBillingResponse.ok
    var throwOnQuery = false;
    var ready = true;
    final queriedTypes = <int>[];
    final methods = <String, Object? Function(Object?)>{
      'startConnection': (_) => _result(3),
      'isReady': (_) => ready,
      'queryProductDetailsAsync': (_) => _WireValue(141, [_result(3), [], []]),
      'queryPurchasesAsync': (message) {
        final type = ((message as List).single as _WireValue).value as int;
        queriedTypes.add(type);
        return _WireValue(
            150, [_result(responseCode), type == 1 ? subscriptions : []]);
      },
    };
    for (final entry in methods.entries) {
      messenger.setMockMessageHandler('$prefix${entry.key}', (message) async {
        if (entry.key == 'queryPurchasesAsync' && throwOnQuery) {
          return codec.encodeMessage(['billing_error', 'offline', null]);
        }
        return codec.encodeMessage([entry.value(codec.decodeMessage(message))]);
      });
      addTearDown(
          () => messenger.setMockMessageHandler('$prefix${entry.key}', null));
    }
    final preferences = await SharedPreferences.getInstance();
    final subject = PurchaseService.forTesting(
      preferences: preferences,
      initialized: false,
      isAndroidPlatform: true,
      androidPurchasesLoader: () =>
          queryAndroidSubscriptions(InAppPurchase.instance),
    );
    addTearDown(subject.dispose);
    await subject.initialize();
    expect(queriedTypes, everyElement(1));
    expect(subject.isPremium, false); // Successful empty startup snapshot.
    expect(preferences.getBool('premium_active'), false);

    subscriptions = [_purchase(state: 1, autoRenewing: false)];
    final queried = await queryAndroidSubscriptions(InAppPurchase.instance);
    expect(queried.single.status.name, 'purchased');
    await subject.restorePurchases();
    expect(subject.isPremium, true); // Canceled renewal, still purchased.
    expect(preferences.getBool('premium_active'), true);

    ready = false;
    final queriesBeforeDisconnect = queriedTypes.length;
    await subject.restorePurchases();
    expect(subject.isPremium, true);
    expect(queriedTypes.length, queriesBeforeDisconnect);
    ready = true;

    subscriptions = [];
    responseCode = 9; // PlatformBillingResponse.error, not an empty success.
    await subject.restorePurchases();
    expect(subject.isPremium, true);
    expect(subject.errorMessage, isNotNull);

    responseCode = 3;
    throwOnQuery = true;
    await subject.restorePurchases();
    expect(subject.isPremium, true);
    throwOnQuery = false;

    subscriptions = [_purchase(state: 2)]; // PENDING must stay pending.
    await subject.restorePurchases();
    expect(subject.isPremium, false);
    expect(preferences.getBool('premium_active'), false);

    subscriptions = [_purchase(state: 1)]; // Includes grace-period purchases.
    responseCode = 9;
    await subject.restorePurchases();
    expect(subject.isPremium, false); // Partial error must not grant either.
    responseCode = 3;
    await subject.restorePurchases();
    expect(subject.isPremium, true);
    subscriptions = [];
    await subject.restorePurchases();
    expect(subject.isPremium, false);
    expect(subject.errorMessage, isNull);
  });
}

_WireValue _result(int code) => _WireValue(138, [_WireValue(129, code), '', 0]);

_WireValue _purchase({required int state, bool autoRenewing = true}) =>
    _WireValue(146, [
      'GPA.test-order',
      'com.rodiziobrinquedos.v3',
      1,
      'test-token',
      'test-signature',
      [PurchaseService.monthlyProductId],
      autoRenewing,
      '{}',
      '',
      true, // Already acknowledged.
      1,
      _WireValue(134, state),
      null,
      null,
    ]);

class _WireValue {
  const _WireValue(this.type, this.value);
  final int type;
  final Object? value;
}

// Wire tags/layout from the pinned in_app_purchase_android messages.g.dart.
// Keeping the fixture at the transport boundary avoids replacing the plugin
// implementation under test or adding dependency declarations just for tests.
class _BillingCodec extends StandardMessageCodec {
  const _BillingCodec();

  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is _WireValue) {
      buffer.putUint8(value.type);
      writeValue(buffer, value.value);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    if (type >= 129 && type <= 156) {
      return _WireValue(type, readValue(buffer));
    }
    return super.readValueOfType(type, buffer);
  }
}

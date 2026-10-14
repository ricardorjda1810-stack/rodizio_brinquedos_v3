import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PurchaseService> service({
    required Future<List<PurchaseDetails>> Function() query,
    bool premium = true,
    bool android = true,
    bool paywallEnabled = true,
    Stream<List<PurchaseDetails>>? stream,
    Future<void> Function(PurchaseDetails)? completePurchase,
  }) async {
    SharedPreferences.setMockInitialValues({'premium_active': premium});
    final result = PurchaseService.forTesting(
      preferences: await SharedPreferences.getInstance(),
      isPremium: premium,
      isAndroidPlatform: android,
      initialized: false,
      androidPurchasesLoader: query,
      purchaseStream: stream,
      paywallEnabled: paywallEnabled,
      completePurchase: completePurchase,
    );
    addTearDown(result.dispose);
    return result;
  }

  Future<void> expectPremium(PurchaseService service, bool value) async {
    expect(service.isPremium, value);
    expect(service.hasPremiumAccess, value);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('premium_active'), value);
  }

  test('startup removes persisted Premium after successful empty query',
      () async {
    var queries = 0;
    final subject = await service(query: () async {
      queries++;
      return [];
    });
    await subject.initialize();
    await subject.initialize();
    expect(queries, 1);
    await expectPremium(subject, false);
  });

  test('resume outside paywall rechecks ownership and revokes expired access',
      () async {
    var purchases = [_purchase()];
    var queries = 0;
    final subject = await service(query: () async {
      queries++;
      return purchases;
    });
    await subject.initialize();
    purchases = [];
    subject.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(queries, 1);
    // Exercise registration with WidgetsBinding, not a paywall widget.
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(queries, 2);
    await expectPremium(subject, false);
  });

  test('explicit restore revokes when only unrelated purchases remain',
      () async {
    final subject = await service(query: () async => [_purchase(id: 'other')]);
    await subject.restorePurchases();
    await expectPremium(subject, false);
    expect(subject.isLoading, false);
    expect(subject.errorMessage, isNull);
  });

  for (final premium in [true, false]) {
    test('query error preserves cached $premium at startup/resume/restore',
        () async {
      final subject = await service(
        premium: premium,
        query: () async => throw StateError('billing unavailable'),
      );
      await subject.initialize();
      await expectPremium(subject, premium);
      subject.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();
      await expectPremium(subject, premium);
      await subject.restorePurchases();
      await expectPremium(subject, premium);
      expect(subject.errorMessage, isNotNull);
      expect(subject.isLoading, false);
    });
  }

  for (final id in PurchaseService.productIds) {
    test('active $id recovers Premium and acknowledges unfinished purchase',
        () async {
      final purchase = _purchase(id: id)..pendingCompletePurchase = true;
      final completed = <PurchaseDetails>[];
      final subject = await service(
        premium: false,
        query: () async => [purchase],
        completePurchase: (value) async => completed.add(value),
      );
      await subject.initialize();
      await expectPremium(subject, true);
      expect(completed, [purchase]);
    });
  }

  test('canceled renewal still PURCHASED retains access regardless of old date',
      () async {
    final subject =
        await service(query: () async => [_purchase(autoRenewing: false)]);
    await subject.restorePurchases();
    await expectPremium(subject, true);
  });

  test('grace period returned as PURCHASED retains access', () async {
    // Billing exposes grace-period subscriptions as purchased, without expiry.
    final subject =
        await service(query: () async => [_purchase(autoRenewing: true)]);
    await subject.restorePurchases();
    await expectPremium(subject, true);
  });

  for (final status in [
    PurchaseStatus.pending,
    PurchaseStatus.canceled,
    PurchaseStatus.error
  ]) {
    test('$status alone does not grant access or acknowledge', () async {
      var completions = 0;
      final subject = await service(
        query: () async =>
            [_purchase(status: status)..pendingCompletePurchase = true],
        completePurchase: (_) async => completions++,
      );
      await subject.restorePurchases();
      await expectPremium(subject, false);
      expect(completions, 0);
    });
  }

  test('active subscription wins over pending/unrelated purchases', () async {
    final subject = await service(
        query: () async => [
              _purchase(status: PurchaseStatus.pending),
              _purchase(id: 'other'),
              _purchase(id: PurchaseService.yearlyProductId),
            ]);
    await subject.restorePurchases();
    await expectPremium(subject, true);
  });

  test('old empty startup query cannot overwrite new purchase callback',
      () async {
    final pending = Completer<List<PurchaseDetails>>();
    final stream = StreamController<List<PurchaseDetails>>();
    addTearDown(stream.close);
    final subject = await service(
        premium: false, query: () => pending.future, stream: stream.stream);
    final initialization = subject.initialize();
    stream.add([_purchase()]);
    await pumpEventQueue();
    await expectPremium(subject, true);
    pending.complete([]);
    await initialization;
    await expectPremium(subject, true);
  });

  test('old empty restore query cannot overwrite new purchase callback',
      () async {
    final pending = Completer<List<PurchaseDetails>>();
    final subject = await service(premium: false, query: () => pending.future);
    final restoring = subject.restorePurchases();
    await subject.handlePurchaseUpdatesForTesting([_purchase()]);
    pending.complete([]);
    await restoring;
    await expectPremium(subject, true);
    expect(subject.errorMessage, isNull);
  });

  test('older active query cannot regrant after newer empty snapshot',
      () async {
    final first = Completer<List<PurchaseDetails>>();
    var count = 0;
    final subject = await service(
        query: () => ++count == 1 ? first.future : Future.value([]));
    final initialization = subject.initialize();
    await subject.restorePurchases();
    first.complete([_purchase()]);
    await initialization;
    await expectPremium(subject, false);
  });

  test('older empty query cannot revoke newer active snapshot', () async {
    final first = Completer<List<PurchaseDetails>>();
    var count = 0;
    final subject = await service(
        premium: false,
        query: () => ++count == 1 ? first.future : Future.value([_purchase()]));
    final initialization = subject.initialize();
    await subject.restorePurchases();
    first.complete([]);
    await initialization;
    await expectPremium(subject, true);
  });

  test('acknowledgement failure does not revoke confirmed ownership', () async {
    final subject = await service(
      premium: false,
      query: () async => [_purchase()..pendingCompletePurchase = true],
      completePurchase: (_) async => throw StateError('acknowledgement failed'),
    );
    await subject.restorePurchases();
    await expectPremium(subject, true);
    expect(subject.errorMessage, isNotNull);
  });

  test('non-Android and disabled paywall never run Android query', () async {
    var queries = 0;
    for (final android in [false, true]) {
      final subject = await service(
          android: android,
          paywallEnabled: !android,
          query: () async {
            queries++;
            return [];
          });
      await subject.initialize();
      subject.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await subject.restorePurchases();
    }
    expect(queries, 0);
  });

  test('disposed service ignores in-flight query and unregisters observer',
      () async {
    SharedPreferences.setMockInitialValues({'premium_active': true});
    final preferences = await SharedPreferences.getInstance();
    final pending = Completer<List<PurchaseDetails>>();
    var queries = 0;
    final subject = PurchaseService.forTesting(
      preferences: preferences,
      isPremium: true,
      isAndroidPlatform: true,
      initialized: false,
      androidPurchasesLoader: () {
        queries++;
        return pending.future;
      },
    );
    await subject.initialize().timeout(Duration.zero, onTimeout: () {});
    subject.dispose();
    pending.complete([]);
    await pumpEventQueue();
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(queries, 1);
    expect(preferences.getBool('premium_active'), true);
  });
}

PurchaseDetails _purchase({
  String id = PurchaseService.monthlyProductId,
  PurchaseStatus status = PurchaseStatus.purchased,
  bool autoRenewing = true,
}) =>
    PurchaseDetails(
      purchaseID: 'GPA.test-order',
      productID: id,
      verificationData: PurchaseVerificationData(
        localVerificationData: jsonEncode({'autoRenewing': autoRenewing}),
        serverVerificationData: 'test-token',
        source: 'google_play',
      ),
      transactionDate: '1',
      status: status,
    );

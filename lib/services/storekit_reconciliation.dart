import 'package:flutter/services.dart';

enum StoreKitReconciliationStatus {
  success,
  unavailable,
  malformed,
  failed,
}

enum StoreKitFinishStatus {
  finished,
  alreadyFinished,
  rejected,
  unavailable,
  failed,
}

class StoreKitReconciliationTransaction {
  const StoreKitReconciliationTransaction({
    required this.transactionId,
    required this.productId,
    required this.verified,
    required this.active,
    required this.revoked,
    required this.expired,
  });

  final String transactionId;
  final String productId;
  final bool verified;
  final bool active;
  final bool revoked;
  final bool expired;

  static StoreKitReconciliationTransaction? tryParse(Object? value) {
    if (value is! Map<Object?, Object?>) return null;

    final transactionId = value['transactionId'];
    final productId = value['productId'];
    final verified = value['verified'];
    final active = value['active'];
    final revoked = value['revoked'];
    final expired = value['expired'];
    if (transactionId is! String ||
        productId is! String ||
        verified is! bool ||
        active is! bool ||
        revoked is! bool ||
        expired is! bool) {
      return null;
    }

    return StoreKitReconciliationTransaction(
      transactionId: transactionId,
      productId: productId,
      verified: verified,
      active: active,
      revoked: revoked,
      expired: expired,
    );
  }
}

class StoreKitReconciliationSnapshot {
  const StoreKitReconciliationSnapshot._({
    required this.status,
    this.unfinished = const <StoreKitReconciliationTransaction>[],
    this.currentEntitlements = const <StoreKitReconciliationTransaction>[],
  });

  const StoreKitReconciliationSnapshot.success({
    required List<StoreKitReconciliationTransaction> unfinished,
    required List<StoreKitReconciliationTransaction> currentEntitlements,
  }) : this._(
          status: StoreKitReconciliationStatus.success,
          unfinished: unfinished,
          currentEntitlements: currentEntitlements,
        );

  const StoreKitReconciliationSnapshot.unavailable()
      : this._(status: StoreKitReconciliationStatus.unavailable);

  const StoreKitReconciliationSnapshot.malformed()
      : this._(status: StoreKitReconciliationStatus.malformed);

  const StoreKitReconciliationSnapshot.failed()
      : this._(status: StoreKitReconciliationStatus.failed);

  final StoreKitReconciliationStatus status;
  final List<StoreKitReconciliationTransaction> unfinished;
  final List<StoreKitReconciliationTransaction> currentEntitlements;
}

abstract interface class StoreKitReconciliationClient {
  Future<StoreKitReconciliationSnapshot> loadSnapshot();

  Future<StoreKitFinishStatus> finish(
    StoreKitReconciliationTransaction transaction,
  );
}

class MethodChannelStoreKitReconciliationClient
    implements StoreKitReconciliationClient {
  const MethodChannelStoreKitReconciliationClient();

  static const MethodChannel _channel = MethodChannel(
    'com.rodiziobrinquedos.v3/storekit_reconciliation',
  );

  @override
  Future<StoreKitReconciliationSnapshot> loadSnapshot() async {
    try {
      final response = await _channel.invokeMethod<Object?>('snapshot');
      if (response is! Map<Object?, Object?>) {
        return const StoreKitReconciliationSnapshot.malformed();
      }

      switch (response['status']) {
        case 'success':
          final unfinished = _parseTransactions(response['unfinished']);
          final currentEntitlements =
              _parseTransactions(response['currentEntitlements']);
          if (unfinished == null || currentEntitlements == null) {
            return const StoreKitReconciliationSnapshot.malformed();
          }
          return StoreKitReconciliationSnapshot.success(
            unfinished: unfinished,
            currentEntitlements: currentEntitlements,
          );
        case 'unavailable':
          return const StoreKitReconciliationSnapshot.unavailable();
        default:
          return const StoreKitReconciliationSnapshot.malformed();
      }
    } on MissingPluginException {
      return const StoreKitReconciliationSnapshot.unavailable();
    } on PlatformException {
      return const StoreKitReconciliationSnapshot.failed();
    }
  }

  @override
  Future<StoreKitFinishStatus> finish(
    StoreKitReconciliationTransaction transaction,
  ) async {
    try {
      final response =
          await _channel.invokeMethod<Object?>('finish', <String, String>{
        'transactionId': transaction.transactionId,
        'productId': transaction.productId,
      });
      if (response is! Map<Object?, Object?>) {
        return StoreKitFinishStatus.failed;
      }
      return switch (response['status']) {
        'finished' => StoreKitFinishStatus.finished,
        'notFound' => StoreKitFinishStatus.alreadyFinished,
        'rejected' => StoreKitFinishStatus.rejected,
        'unavailable' => StoreKitFinishStatus.unavailable,
        _ => StoreKitFinishStatus.failed,
      };
    } on MissingPluginException {
      return StoreKitFinishStatus.unavailable;
    } on PlatformException {
      return StoreKitFinishStatus.failed;
    }
  }

  List<StoreKitReconciliationTransaction>? _parseTransactions(Object? value) {
    if (value is! List<Object?>) return null;

    final parsed = <StoreKitReconciliationTransaction>[];
    for (final item in value) {
      final transaction = StoreKitReconciliationTransaction.tryParse(item);
      if (transaction == null) return null;
      parsed.add(transaction);
    }
    return List<StoreKitReconciliationTransaction>.unmodifiable(parsed);
  }
}

import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'polar_h10_device.dart';
import 'polar_h10_parser.dart';
import 'polar_h10_rr_sample.dart';

class PolarH10Service {
  static final Uuid heartRateServiceUuid = Uuid.parse('180D');
  static final Uuid heartRateMeasurementUuid = Uuid.parse('2A37');

  final FlutterReactiveBle? _providedBle;
  final PolarH10Parser _parser;
  final List<PolarH10RrSample> _recentSamples = [];
  FlutterReactiveBle? _lazyBle;

  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _measurementSubscription;
  String? _connectedDeviceId;
  PolarH10RrSample? _latestSample;

  PolarH10Service({
    FlutterReactiveBle? ble,
    PolarH10Parser parser = const PolarH10Parser(),
  }) : _providedBle = ble,
       _parser = parser;

  FlutterReactiveBle get _ble =>
      _providedBle ?? (_lazyBle ??= FlutterReactiveBle());

  String? get connectedDeviceId => _connectedDeviceId;

  bool get isConnected => _connectedDeviceId != null;

  Future<List<PolarH10Device>> scanDevices({
    Duration duration = const Duration(seconds: 5),
  }) async {
    final devices = <String, PolarH10Device>{};
    final completer = Completer<List<PolarH10Device>>();
    late final StreamSubscription<DiscoveredDevice> subscription;

    subscription = _ble
        .scanForDevices(
          withServices: [heartRateServiceUuid],
          scanMode: ScanMode.balanced,
          requireLocationServicesEnabled: false,
        )
        .listen((device) {
          if (!_looksLikePolar(device)) {
            return;
          }

          devices[device.id] = PolarH10Device(
            id: device.id,
            name: device.name,
            rssi: device.rssi,
            connectable: device.connectable != Connectable.unavailable,
          );
        }, onError: completer.completeError);

    Timer(duration, () async {
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(List.unmodifiable(devices.values));
      }
    });

    return completer.future;
  }

  Future<void> connect(PolarH10Device device) async {
    await disconnect();

    final completer = Completer<void>();
    _connectionSubscription = _ble
        .connectToDevice(
          id: device.id,
          servicesWithCharacteristicsToDiscover: {
            heartRateServiceUuid: [heartRateMeasurementUuid],
          },
          connectionTimeout: const Duration(seconds: 12),
        )
        .listen(
          (update) {
            if (update.connectionState == DeviceConnectionState.connected) {
              _connectedDeviceId = update.deviceId;
              _subscribeToHeartRate(update.deviceId);
              if (!completer.isCompleted) {
                completer.complete();
              }
            } else if (update.connectionState ==
                DeviceConnectionState.disconnected) {
              _connectedDeviceId = null;
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            _connectedDeviceId = null;
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          },
        );

    return completer.future.timeout(const Duration(seconds: 15));
  }

  Future<void> disconnect() async {
    await _measurementSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _measurementSubscription = null;
    _connectionSubscription = null;
    _connectedDeviceId = null;
  }

  Future<PolarH10RrSample?> getLatestRrSample() async {
    return _latestSample;
  }

  Future<List<PolarH10RrSample>> getRecentRrSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    return List.unmodifiable(_recentSamples.reversed.take(limit));
  }

  void _subscribeToHeartRate(String deviceId) {
    final characteristic = QualifiedCharacteristic(
      serviceId: heartRateServiceUuid,
      characteristicId: heartRateMeasurementUuid,
      deviceId: deviceId,
    );

    _measurementSubscription = _ble
        .subscribeToCharacteristic(characteristic)
        .listen(_handleMeasurement);
  }

  void _handleMeasurement(List<int> value) {
    final measurement = _parser.parseHeartRateMeasurement(value);
    if (measurement == null || measurement.rrSamples.isEmpty) {
      return;
    }

    _recentSamples.addAll(measurement.rrSamples);
    if (_recentSamples.length > 300) {
      _recentSamples.removeRange(0, _recentSamples.length - 300);
    }
    _latestSample = measurement.latestRrSample;
  }

  bool _looksLikePolar(DiscoveredDevice device) {
    final normalizedName = device.name.toLowerCase();
    return normalizedName.contains('polar') ||
        device.serviceUuids.contains(heartRateServiceUuid);
  }
}

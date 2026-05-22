import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'polar_h10_device.dart';
import 'polar_h10_models.dart';
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
  PolarH10ConnectionStatus _connectionStatus =
      PolarH10ConnectionStatus.disconnected;
  List<PolarH10Device> _lastScanDevices = const [];
  DateTime? _lastScanStartedAt;
  DateTime? _lastScanCompletedAt;
  DateTime? _connectedAt;
  DateTime? _lastHeartRateAt;
  Object? _lastError;
  int _heartRateSampleCount = 0;
  int _rrIntervalCount = 0;
  int _discardedRrIntervalCount = 0;

  PolarH10Service({
    FlutterReactiveBle? ble,
    PolarH10Parser parser = const PolarH10Parser(),
  }) : _providedBle = ble,
       _parser = parser;

  FlutterReactiveBle get _ble =>
      _providedBle ?? (_lazyBle ??= FlutterReactiveBle());

  String? get connectedDeviceId => _connectedDeviceId;

  bool get isConnected => _connectedDeviceId != null;

  PolarH10ConnectionStatus get connectionStatus => _connectionStatus;

  List<PolarH10Device> get lastScanDevices => _lastScanDevices;

  DateTime? get lastScanStartedAt => _lastScanStartedAt;

  DateTime? get lastScanCompletedAt => _lastScanCompletedAt;

  DateTime? get connectedAt => _connectedAt;

  DateTime? get lastHeartRateAt => _lastHeartRateAt;

  Object? get lastError => _lastError;

  int get heartRateSampleCount => _heartRateSampleCount;

  int get rrIntervalCount => _rrIntervalCount;

  int get discardedRrIntervalCount => _discardedRrIntervalCount;

  Future<List<PolarH10Device>> scanDevices({
    Duration duration = const Duration(seconds: 5),
  }) async {
    final devices = <String, PolarH10Device>{};
    final completer = Completer<List<PolarH10Device>>();
    late final StreamSubscription<DiscoveredDevice> subscription;
    _connectionStatus = PolarH10ConnectionStatus.scanning;
    _lastError = null;
    _lastScanStartedAt = DateTime.now();
    _lastScanCompletedAt = null;
    _lastScanDevices = const [];

    subscription = _ble
        .scanForDevices(
          withServices: [heartRateServiceUuid],
          scanMode: ScanMode.balanced,
          requireLocationServicesEnabled: false,
        )
        .listen(
          (device) {
            if (!_looksLikePolar(device)) {
              return;
            }

            devices[device.id] = PolarH10Device(
              id: device.id,
              name: device.name,
              rssi: device.rssi,
              connectable: device.connectable != Connectable.unavailable,
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            _lastError = error;
            _connectionStatus = _connectedDeviceId == null
                ? PolarH10ConnectionStatus.disconnected
                : PolarH10ConnectionStatus.connected;
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          },
        );

    Timer(duration, () async {
      await subscription.cancel();
      if (!completer.isCompleted) {
        _lastScanDevices = List.unmodifiable(devices.values);
        _lastScanCompletedAt = DateTime.now();
        _connectionStatus = _connectedDeviceId == null
            ? PolarH10ConnectionStatus.disconnected
            : PolarH10ConnectionStatus.connected;
        completer.complete(_lastScanDevices);
      }
    });

    return completer.future;
  }

  Future<void> connect(PolarH10Device device) async {
    await disconnect();

    final completer = Completer<void>();
    _connectionStatus = PolarH10ConnectionStatus.connecting;
    _lastError = null;
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
              _connectionStatus = PolarH10ConnectionStatus.connected;
              _connectedAt = DateTime.now();
              _subscribeToHeartRate(update.deviceId);
              if (!completer.isCompleted) {
                completer.complete();
              }
            } else if (update.connectionState ==
                DeviceConnectionState.disconnected) {
              _connectedDeviceId = null;
              _connectionStatus = PolarH10ConnectionStatus.disconnected;
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            _connectedDeviceId = null;
            _connectionStatus = PolarH10ConnectionStatus.disconnected;
            _lastError = error;
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
    _connectionStatus = PolarH10ConnectionStatus.disconnected;
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

    _heartRateSampleCount += 1;
    _rrIntervalCount += measurement.rrSamples.length;
    _discardedRrIntervalCount += measurement.rrSamples
        .where((sample) => !sample.isValid)
        .length;
    _recentSamples.addAll(measurement.rrSamples);
    if (_recentSamples.length > 300) {
      _recentSamples.removeRange(0, _recentSamples.length - 300);
    }
    _latestSample = measurement.latestRrSample;
    _lastHeartRateAt = _latestSample?.timestamp ?? DateTime.now();
  }

  bool _looksLikePolar(DiscoveredDevice device) {
    final normalizedName = device.name.toLowerCase();
    return normalizedName.contains('polar') ||
        device.serviceUuids.contains(heartRateServiceUuid);
  }
}

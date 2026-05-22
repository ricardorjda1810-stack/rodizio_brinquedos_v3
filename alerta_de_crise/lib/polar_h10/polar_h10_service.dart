import 'dart:async';
import 'dart:math';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'polar_h10_accelerometer_sample.dart';
import 'polar_h10_device.dart';
import 'polar_h10_models.dart';
import 'polar_h10_parser.dart';
import 'polar_h10_rr_sample.dart';

class PolarH10Service {
  static final Uuid heartRateServiceUuid = Uuid.parse('180D');
  static final Uuid heartRateMeasurementUuid = Uuid.parse('2A37');
  static final Uuid pmdServiceUuid = Uuid.parse(
    'FB005C80-02E7-F387-1CAD-8ACD2D8DF0C8',
  );
  static final Uuid pmdControlPointUuid = Uuid.parse(
    'FB005C81-02E7-F387-1CAD-8ACD2D8DF0C8',
  );
  static final Uuid pmdDataUuid = Uuid.parse(
    'FB005C82-02E7-F387-1CAD-8ACD2D8DF0C8',
  );
  static const Duration accelerometerWindow = Duration(seconds: 8);

  final FlutterReactiveBle? _providedBle;
  final PolarH10Parser _parser;
  final List<PolarH10RrSample> _recentSamples = [];
  final List<PolarH10AccelerometerSample> _recentAccelerometerSamples = [];
  FlutterReactiveBle? _lazyBle;

  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _measurementSubscription;
  StreamSubscription<List<int>>? _accelerometerSubscription;
  String? _connectedDeviceId;
  PolarH10RrSample? _latestSample;
  PolarH10AccelerometerSample? _latestAccelerometerSample;
  PolarH10ConnectionStatus _connectionStatus =
      PolarH10ConnectionStatus.disconnected;
  List<PolarH10Device> _lastScanDevices = const [];
  DateTime? _lastScanStartedAt;
  DateTime? _lastScanCompletedAt;
  DateTime? _connectedAt;
  DateTime? _lastHeartRateAt;
  Object? _lastError;
  Object? _lastAccelerometerError;
  int _heartRateSampleCount = 0;
  int _rrIntervalCount = 0;
  int _discardedRrIntervalCount = 0;
  int _accelerometerSampleCount = 0;
  bool _accelerometerActive = false;

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

  Object? get lastAccelerometerError => _lastAccelerometerError;

  int get heartRateSampleCount => _heartRateSampleCount;

  int get rrIntervalCount => _rrIntervalCount;

  int get discardedRrIntervalCount => _discardedRrIntervalCount;

  bool get isAccelerometerActive => _accelerometerActive;

  int get accelerometerSampleCount => _accelerometerSampleCount;

  PolarH10AccelerometerSample? get latestAccelerometerSample =>
      _latestAccelerometerSample;

  double? get motionRmsMg => _motionRmsMg();

  PolarH10MotionClass get motionClass => _motionClass();

  double get movementIntensity => motionClass.intensity;

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
            pmdServiceUuid: [pmdControlPointUuid, pmdDataUuid],
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
              _startAccelerometerStream(update.deviceId);
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
    await _accelerometerSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _measurementSubscription = null;
    _accelerometerSubscription = null;
    _connectionSubscription = null;
    _connectedDeviceId = null;
    _connectionStatus = PolarH10ConnectionStatus.disconnected;
    _accelerometerActive = false;
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

  void _startAccelerometerStream(String deviceId) {
    final controlPoint = QualifiedCharacteristic(
      serviceId: pmdServiceUuid,
      characteristicId: pmdControlPointUuid,
      deviceId: deviceId,
    );
    final data = QualifiedCharacteristic(
      serviceId: pmdServiceUuid,
      characteristicId: pmdDataUuid,
      deviceId: deviceId,
    );

    _lastAccelerometerError = null;
    _accelerometerActive = false;
    _accelerometerSubscription = _ble
        .subscribeToCharacteristic(data)
        .listen(
          _handleAccelerometerData,
          onError: (Object error, StackTrace stackTrace) {
            _lastAccelerometerError = error;
            _accelerometerActive = false;
          },
        );

    unawaited(
      _ble
          .writeCharacteristicWithResponse(
            controlPoint,
            value: const [
              0x02, // start measurement
              0x02, // online ACC measurement
              0x00, 0x01, 0x19, 0x00, // sample rate 25 Hz
              0x01, 0x01, 0x10, 0x00, // resolution 16 bits
              0x02, 0x01, 0x02, 0x00, // range 2G
            ],
          )
          .catchError((Object error) {
            _lastAccelerometerError = error;
            _accelerometerActive = false;
          }),
    );
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

  void _handleAccelerometerData(List<int> value) {
    try {
      final samples = _parseAccelerometerSamples(value);
      if (samples.isEmpty) {
        return;
      }

      _lastAccelerometerError = null;
      _accelerometerActive = true;
      _accelerometerSampleCount += samples.length;
      _recentAccelerometerSamples.addAll(samples);
      _latestAccelerometerSample = samples.last;
      _trimAccelerometerWindow();
    } catch (error) {
      _lastAccelerometerError = error;
      _accelerometerActive = false;
    }
  }

  List<PolarH10AccelerometerSample> _parseAccelerometerSamples(
    List<int> value,
  ) {
    if (value.length < 10 || value.first != 0x02) {
      return const [];
    }

    final frameType = value[9];
    final stride = switch (frameType) {
      0 => 3,
      1 => 6,
      2 => 9,
      _ => throw FormatException('ACC frame type não suportado: $frameType'),
    };
    final timestamp = _pmdTimestamp(value);
    final receivedAt = DateTime.now();
    final samples = <PolarH10AccelerometerSample>[];
    for (var offset = 10; offset + stride <= value.length; offset += stride) {
      final (:x, :y, :z) = switch (frameType) {
        0 => (
          x: _toSigned8(value[offset]),
          y: _toSigned8(value[offset + 1]),
          z: _toSigned8(value[offset + 2]),
        ),
        1 => (
          x: _toSigned16(value, offset),
          y: _toSigned16(value, offset + 2),
          z: _toSigned16(value, offset + 4),
        ),
        2 => (
          x: _toSigned24(value, offset),
          y: _toSigned24(value, offset + 3),
          z: _toSigned24(value, offset + 6),
        ),
        _ => (x: 0, y: 0, z: 0),
      };
      samples.add(
        PolarH10AccelerometerSample(
          timestamp: timestamp,
          receivedAt: receivedAt,
          xMg: x,
          yMg: y,
          zMg: z,
        ),
      );
    }

    return samples;
  }

  DateTime _pmdTimestamp(List<int> value) {
    var timestampNs = 0;
    for (var i = 0; i < 8; i += 1) {
      timestampNs |= value[1 + i] << (8 * i);
    }
    final millisecondsSince2000 = timestampNs ~/ 1000000;
    return DateTime.utc(
      2000,
    ).add(Duration(milliseconds: millisecondsSince2000)).toLocal();
  }

  int _toSigned8(int value) {
    return value >= 0x80 ? value - 0x100 : value;
  }

  int _toSigned16(List<int> value, int offset) {
    final raw = value[offset] | (value[offset + 1] << 8);
    return raw >= 0x8000 ? raw - 0x10000 : raw;
  }

  int _toSigned24(List<int> value, int offset) {
    final raw =
        value[offset] | (value[offset + 1] << 8) | (value[offset + 2] << 16);
    return raw >= 0x800000 ? raw - 0x1000000 : raw;
  }

  void _trimAccelerometerWindow() {
    final latest = _latestAccelerometerSample?.timestamp;
    if (latest == null) {
      return;
    }

    final windowStart = latest.subtract(accelerometerWindow);
    _recentAccelerometerSamples.removeWhere(
      (sample) => sample.timestamp.isBefore(windowStart),
    );
  }

  double? _motionRmsMg() {
    if (_recentAccelerometerSamples.length < 2) {
      return null;
    }

    final meanX =
        _recentAccelerometerSamples
            .map((sample) => sample.xMg)
            .reduce((a, b) => a + b) /
        _recentAccelerometerSamples.length;
    final meanY =
        _recentAccelerometerSamples
            .map((sample) => sample.yMg)
            .reduce((a, b) => a + b) /
        _recentAccelerometerSamples.length;
    final meanZ =
        _recentAccelerometerSamples
            .map((sample) => sample.zMg)
            .reduce((a, b) => a + b) /
        _recentAccelerometerSamples.length;
    final squaredResiduals = _recentAccelerometerSamples.map((sample) {
      final dx = sample.xMg - meanX;
      final dy = sample.yMg - meanY;
      final dz = sample.zMg - meanZ;
      return dx * dx + dy * dy + dz * dz;
    });
    final average =
        squaredResiduals.reduce((a, b) => a + b) /
        _recentAccelerometerSamples.length;
    return sqrt(average);
  }

  PolarH10MotionClass _motionClass() {
    final rms = motionRmsMg;
    if (rms == null) {
      return PolarH10MotionClass.unavailable;
    }
    if (rms <= PolarH10MotionThresholds.stillnessRmsMg) {
      return PolarH10MotionClass.still;
    }
    if (rms <= PolarH10MotionThresholds.lightMotionRmsMg) {
      return PolarH10MotionClass.light;
    }
    if (rms <= PolarH10MotionThresholds.moderateMotionRmsMg) {
      return PolarH10MotionClass.moderate;
    }
    return PolarH10MotionClass.high;
  }

  bool _looksLikePolar(DiscoveredDevice device) {
    final normalizedName = device.name.toLowerCase();
    return normalizedName.contains('polar') ||
        device.serviceUuids.contains(heartRateServiceUuid);
  }
}

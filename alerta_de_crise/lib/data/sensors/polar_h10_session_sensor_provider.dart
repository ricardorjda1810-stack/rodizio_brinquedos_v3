import 'dart:async';

import '../../core/crisis_detection/polar_h10_sensor_provider.dart';
import '../../domain/models/sensor_sample.dart';
import '../../polar_h10/polar_h10_accelerometer_sample.dart';
import '../../polar_h10/polar_h10_device.dart';
import '../../polar_h10/polar_h10_models.dart';
import '../../polar_h10/polar_h10_rr_sample.dart';
import '../../polar_h10/polar_h10_service.dart';
import '../../polar_h10/polar_h10_statistics.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import 'sensor_provider.dart';

final class PolarH10SessionSensorProvider
    implements SensorProvider, ResettableSensorDeduplication {
  PolarH10SessionSensorProvider._shared(this._service)
    : _provider = PolarH10SensorProvider(service: _service);

  factory PolarH10SessionSensorProvider.shared({PolarH10Service? service}) {
    return PolarH10SessionSensorProvider._shared(service ?? PolarH10Service());
  }

  final PolarH10Service _service;
  final PolarH10SensorProvider _provider;
  List<PolarH10Device> _devices = const [];
  PolarH10Device? _selectedDevice;
  String _permissionStatusMessage =
      'Polar H10 não conectado. Inicie um scan BLE.';
  String? _lastEmittedSampleId;
  DateTime? _lastConnectionAttemptAt;
  PolarH10RrSample? _latestRr;
  PolarH10Statistics _latestStatistics = const PolarH10Statistics(
    sampleCount: 0,
    averageRrMs: null,
    sdnnMs: null,
    rmssdMs: null,
    minHeartRate: null,
    maxHeartRate: null,
  );

  @override
  SensorProviderType get type => SensorProviderType.polarH10;

  @override
  String get permissionStatusMessage => _permissionStatusMessage;

  PolarH10Diagnostics get diagnostics {
    return PolarH10Diagnostics(
      providerLabel: 'Polar H10',
      bluetoothStatus: _bluetoothStatusLabel(),
      scanStarted: _service.lastScanStartedAt != null,
      devices: _devices,
      selectedDevice: _selectedDevice,
      h10Connected: _service.isConnected,
      connectionStatus: _service.connectionStatus,
      lastError: _service.lastError,
      lastConnectionAttemptAt: _lastConnectionAttemptAt,
      connectedAt: _service.connectedAt,
      lastHeartRateAt: _service.lastHeartRateAt,
      latestRr: _latestRr,
      statistics: _latestStatistics,
      qualityEvaluation: _provider.lastQualityEvaluation,
      heartRateSampleCount: _service.heartRateSampleCount,
      rrIntervalCount: _service.rrIntervalCount,
      discardedRrIntervalCount: _service.discardedRrIntervalCount,
      accelerometerActive: _service.isAccelerometerActive,
      latestAccelerometerSample: _service.latestAccelerometerSample,
      accelerometerSampleCount: _service.accelerometerSampleCount,
      motionRmsMg: _service.motionRmsMg,
      motionClass: _service.motionClass,
      lastAccelerometerError: _service.lastAccelerometerError,
    );
  }

  Future<List<PolarH10Device>> scanDevices() async {
    _permissionStatusMessage = 'Scan BLE Polar H10 iniciado.';
    _devices = await _service.scanDevices();
    _permissionStatusMessage = _devices.isEmpty
        ? 'Nenhum Polar H10 encontrado.'
        : 'Polar H10 encontrado: ${_devices.length} dispositivo(s).';
    return _devices;
  }

  Future<void> connect(PolarH10Device device) async {
    _selectedDevice = device;
    _lastConnectionAttemptAt = DateTime.now();
    _permissionStatusMessage = 'Conectando ao Polar H10...';
    await _service.connect(device);
    _permissionStatusMessage = 'Polar H10 conectado.';
  }

  Future<PolarH10RrSample?> latestRrSample() {
    return _service.getLatestRrSample();
  }

  Future<PolarH10Statistics> latestStatistics({int limit = 30}) async {
    final samples = await _service.getRecentRrSamples(limit: limit);
    return PolarH10Statistics.fromSamples(samples);
  }

  SensorQualityEvaluation? get lastQualityEvaluation =>
      _provider.lastQualityEvaluation;

  @override
  Future<SensorSample?> getLatestSample() async {
    final physiologicalSample = await _provider.getLatestSample();
    _latestRr = await _service.getLatestRrSample();
    _latestStatistics = await latestStatistics();
    if (physiologicalSample == null) {
      _permissionStatusMessage = _service.isConnected
          ? 'Polar H10 conectado. Aguardando RR/HRV válido.'
          : 'Polar H10 não conectado.';
      return null;
    }

    final rmssd = physiologicalSample.hrvRmssdMs;
    if (rmssd == null || rmssd <= 0) {
      _permissionStatusMessage =
          'Polar H10 enviou FC/RR, mas HRV ainda não tem janela suficiente.';
      return null;
    }

    _permissionStatusMessage = 'Último dado do Polar H10 carregado.';
    return SensorSample(
      id:
          'polar-h10-${physiologicalSample.timestamp.microsecondsSinceEpoch}'
          '-${_service.rrIntervalCount}',
      timestamp: physiologicalSample.timestamp,
      heartRate: physiologicalSample.heartRateBpm.round(),
      hrv: rmssd.round(),
      motionState: _service.motionClass.label,
    );
  }

  @override
  Future<bool> requestPermissions() async {
    _permissionStatusMessage =
        'A autorização Bluetooth será validada ao procurar o Polar H10.';
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    return _service.lastError == null;
  }

  @override
  Stream<SensorSample> watchSamples() {
    Timer? timer;
    final controller = StreamController<SensorSample>();

    Future<void> poll() async {
      final sample = await getLatestSample();
      if (controller.isClosed || sample == null) {
        return;
      }
      if (sample.id == _lastEmittedSampleId) {
        return;
      }

      _lastEmittedSampleId = sample.id;
      controller.add(sample);
    }

    controller.onListen = () {
      unawaited(poll());
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        unawaited(poll());
      });
    };
    controller.onCancel = () {
      timer?.cancel();
      timer = null;
    };

    return controller.stream;
  }

  @override
  void resetDeduplication() {
    _lastEmittedSampleId = null;
  }

  String _bluetoothStatusLabel() {
    if (_service.lastError != null) {
      return 'erro reportado pelo BLE: ${_service.lastError}';
    }
    if (_service.connectionStatus == PolarH10ConnectionStatus.scanning ||
        _service.connectionStatus == PolarH10ConnectionStatus.connecting ||
        _service.connectionStatus == PolarH10ConnectionStatus.connected) {
      return 'inferido como disponível pelo fluxo BLE';
    }
    return 'não verificado diretamente; procure o Polar H10';
  }
}

final class PolarH10Diagnostics {
  const PolarH10Diagnostics({
    required this.providerLabel,
    required this.bluetoothStatus,
    required this.scanStarted,
    required this.devices,
    required this.selectedDevice,
    required this.h10Connected,
    required this.connectionStatus,
    required this.lastError,
    required this.lastConnectionAttemptAt,
    required this.connectedAt,
    required this.lastHeartRateAt,
    required this.latestRr,
    required this.statistics,
    required this.qualityEvaluation,
    required this.heartRateSampleCount,
    required this.rrIntervalCount,
    required this.discardedRrIntervalCount,
    required this.accelerometerActive,
    required this.latestAccelerometerSample,
    required this.accelerometerSampleCount,
    required this.motionRmsMg,
    required this.motionClass,
    required this.lastAccelerometerError,
  });

  factory PolarH10Diagnostics.empty() {
    return const PolarH10Diagnostics(
      providerLabel: 'Polar H10',
      bluetoothStatus: 'não verificado diretamente; procure o Polar H10',
      scanStarted: false,
      devices: [],
      selectedDevice: null,
      h10Connected: false,
      connectionStatus: PolarH10ConnectionStatus.disconnected,
      lastError: null,
      lastConnectionAttemptAt: null,
      connectedAt: null,
      lastHeartRateAt: null,
      latestRr: null,
      statistics: PolarH10Statistics(
        sampleCount: 0,
        averageRrMs: null,
        sdnnMs: null,
        rmssdMs: null,
        minHeartRate: null,
        maxHeartRate: null,
      ),
      qualityEvaluation: null,
      heartRateSampleCount: 0,
      rrIntervalCount: 0,
      discardedRrIntervalCount: 0,
      accelerometerActive: false,
      latestAccelerometerSample: null,
      accelerometerSampleCount: 0,
      motionRmsMg: null,
      motionClass: PolarH10MotionClass.unavailable,
      lastAccelerometerError: null,
    );
  }

  final String providerLabel;
  final String bluetoothStatus;
  final bool scanStarted;
  final List<PolarH10Device> devices;
  final PolarH10Device? selectedDevice;
  final bool h10Connected;
  final PolarH10ConnectionStatus connectionStatus;
  final Object? lastError;
  final DateTime? lastConnectionAttemptAt;
  final DateTime? connectedAt;
  final DateTime? lastHeartRateAt;
  final PolarH10RrSample? latestRr;
  final PolarH10Statistics statistics;
  final SensorQualityEvaluation? qualityEvaluation;
  final int heartRateSampleCount;
  final int rrIntervalCount;
  final int discardedRrIntervalCount;
  final bool accelerometerActive;
  final PolarH10AccelerometerSample? latestAccelerometerSample;
  final int accelerometerSampleCount;
  final double? motionRmsMg;
  final PolarH10MotionClass motionClass;
  final Object? lastAccelerometerError;

  bool get h10Found => devices.isNotEmpty;

  int get validRrIntervalCount =>
      (rrIntervalCount - discardedRrIntervalCount).clamp(0, rrIntervalCount);
}

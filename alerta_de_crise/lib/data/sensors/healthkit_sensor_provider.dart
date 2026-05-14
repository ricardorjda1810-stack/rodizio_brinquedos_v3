import 'dart:async';
import 'dart:developer' as developer;

import 'package:health/health.dart';

import '../../domain/models/sensor_sample.dart';
import 'sensor_provider.dart';

final class HealthKitSensorProvider implements SensorProvider {
  HealthKitSensorProvider({Health? health}) : _health = health ?? Health();

  static const List<HealthDataType> plannedTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
  ];

  static const List<HealthDataAccess> plannedPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  final Health _health;
  String _permissionStatusMessage = 'Permissão HealthKit ainda não solicitada.';
  static const int _fallbackHrv = 40;
  static const Duration _diagnosticWindow = Duration(minutes: 30);

  @override
  SensorProviderType get type => SensorProviderType.healthkit;

  @override
  String get permissionStatusMessage => _permissionStatusMessage;

  @override
  Future<bool> requestPermissions() async {
    _debugLog('requestPermissions iniciado.');
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        plannedTypes,
        permissions: plannedPermissions,
      );
      _permissionStatusMessage = granted
          ? 'Permissão HealthKit concedida.'
          : 'Permissão HealthKit não concedida.';
      _debugLog('requestPermissions resultado: $granted.');
      return granted;
    } catch (error) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente.';
      _debugLog('requestPermissions erro: $error.');
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    _debugLog('hasPermissions iniciado.');
    try {
      await _health.configure();
      final granted = await _health.hasPermissions(
        plannedTypes,
        permissions: plannedPermissions,
      );
      if (granted == null) {
        _permissionStatusMessage =
            'O iOS não informa o status de leitura do HealthKit. Solicite permissão para continuar a preparação.';
        _debugLog('hasPermissions retornou null.');
        return false;
      }
      _permissionStatusMessage = granted
          ? 'Permissão HealthKit concedida.'
          : 'Permissão HealthKit ainda não concedida.';
      _debugLog('hasPermissions resultado: $granted.');
      return granted;
    } catch (error) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente.';
      _debugLog('hasPermissions erro: $error.');
      return false;
    }
  }

  @override
  Future<SensorSample?> getLatestSample() async {
    try {
      final canRead = await _ensurePermissionsForRead();
      if (!canRead) {
        _permissionStatusMessage = 'Permissão HealthKit necessária.';
        return null;
      }

      final window = _debugWindow();
      final heartRatePoints = await _pointsForType(
        HealthDataType.HEART_RATE,
        window.start,
        window.end,
      );
      final heartRatePoint = _latestFromPoints(heartRatePoints);
      if (heartRatePoint == null) {
        _permissionStatusMessage =
            'Nenhum dado recente encontrado no HealthKit.';
        _debugLog(
          'Nenhum HEART_RATE encontrado nos últimos ${_diagnosticWindow.inMinutes} minutos.',
        );
        return null;
      }

      final hrvPoints = await _pointsForType(
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
        window.start,
        window.end,
      );
      final hrvPoint = _latestFromPoints(hrvPoints);
      final heartRate = _numericValue(heartRatePoint)?.round();
      if (heartRate == null || heartRate <= 0) {
        _permissionStatusMessage =
            'Nenhum dado recente encontrado no HealthKit.';
        _debugLog('HEART_RATE encontrado sem valor numérico válido.');
        return null;
      }

      final hrv = _numericValue(hrvPoint)?.round();
      final hasRealHrv = hrv != null && hrv > 0;
      final timestamp = _latestTimestamp(heartRatePoint, hrvPoint);
      _permissionStatusMessage = hasRealHrv
          ? 'Último dado do HealthKit carregado.'
          : 'Última frequência cardíaca carregada. HRV recente não encontrado.';
      _debugLog(
        'Leitura HealthKit: FC=${heartRatePoint.dateTo.toIso8601String()} '
        'valor=$heartRate, HRV=${hrvPoint?.dateTo.toIso8601String() ?? 'não encontrado'} '
        'valor=${hasRealHrv ? hrv : 'indisponível'}, '
        'counts FC=${heartRatePoints.length} HRV=${hrvPoints.length}.',
      );

      return SensorSample(
        id:
            'healthkit-${timestamp.microsecondsSinceEpoch}'
            '${hasRealHrv ? '' : '-fc-only'}',
        timestamp: timestamp,
        heartRate: heartRate,
        hrv: hasRealHrv ? hrv : _fallbackHrv,
        motionState: hasRealHrv ? 'healthkit' : 'healthkit-hrv-indisponivel',
      );
    } catch (error) {
      _permissionStatusMessage =
          'Não foi possível ler dados recentes do HealthKit.';
      _debugLog('getLatestSample erro: $error.');
      return null;
    }
  }

  Future<String> debugHealthKitStatus() async {
    final lines = <String>[
      'Diagnóstico bruto HealthKit',
      'Janela: últimos ${_diagnosticWindow.inMinutes} minutos',
      'Executado em: ${DateTime.now().toIso8601String()}',
    ];

    try {
      final canRead = await _ensurePermissionsForRead();
      lines.add('Permissões: ${canRead ? 'concedidas' : 'não concedidas'}');
      lines.add('Mensagem de permissão: $_permissionStatusMessage');
      _debugLog('debugHealthKitStatus permissões: $canRead.');

      if (!canRead) {
        lines.add('Permissão HealthKit necessária.');
        return lines.join('\n');
      }

      final window = _debugWindow();
      final heartRatePoints = await _pointsForType(
        HealthDataType.HEART_RATE,
        window.start,
        window.end,
      );
      final hrvPoints = await _pointsForType(
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
        window.start,
        window.end,
      );
      final heartRatePoint = _latestFromPoints(heartRatePoints);
      final hrvPoint = _latestFromPoints(hrvPoints);
      final heartRate = _numericValue(heartRatePoint);
      final hrv = _numericValue(hrvPoint);

      lines
        ..add('Samples HEART_RATE na janela: ${heartRatePoints.length}')
        ..add('Samples HRV_SDNN na janela: ${hrvPoints.length}')
        ..add(
          'Último FC encontrado: ${heartRate == null ? 'não encontrado' : heartRate.round()}',
        )
        ..add(
          'Timestamp FC: ${heartRatePoint?.dateTo.toIso8601String() ?? 'não encontrado'}',
        )
        ..add(
          'Último HRV encontrado: ${hrv == null ? 'não encontrado' : hrv.round()}',
        )
        ..add(
          'Timestamp HRV: ${hrvPoint?.dateTo.toIso8601String() ?? 'não encontrado'}',
        )
        ..add('Tipos consultados: HEART_RATE, HEART_RATE_VARIABILITY_SDNN');

      if (heartRatePoints.isEmpty && hrvPoints.isEmpty) {
        lines.add('Nenhum sample encontrado nos últimos 30 minutos.');
      }

      _debugLog(
        'debugHealthKitStatus counts: HEART_RATE=${heartRatePoints.length}, '
        'HRV_SDNN=${hrvPoints.length}.',
      );
      _debugLog(
        'debugHealthKitStatus latest: FC=${heartRatePoint?.dateTo.toIso8601String() ?? 'n/a'} '
        'HRV=${hrvPoint?.dateTo.toIso8601String() ?? 'n/a'}.',
      );
    } catch (error) {
      lines.add('Erro: $error');
      _debugLog('debugHealthKitStatus erro: $error.');
    }

    return lines.join('\n');
  }

  @override
  Stream<SensorSample> watchSamples() {
    Timer? timer;
    String? lastSampleId;
    final controller = StreamController<SensorSample>();

    Future<void> poll() async {
      final sample = await getLatestSample();
      if (sample == null || sample.id == lastSampleId || controller.isClosed) {
        return;
      }

      lastSampleId = sample.id;
      controller.add(sample);
    }

    controller.onListen = () {
      unawaited(poll());
      timer = Timer.periodic(const Duration(seconds: 15), (_) {
        unawaited(poll());
      });
    };
    controller.onCancel = () {
      timer?.cancel();
      timer = null;
    };

    return controller.stream;
  }

  Future<bool> _ensurePermissionsForRead() async {
    final granted = await hasPermissions();
    if (granted) {
      return true;
    }

    return requestPermissions();
  }

  Future<List<HealthDataPoint>> _pointsForType(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    final points = await _health.getHealthDataFromTypes(
      types: [type],
      preferredUnits: {
        HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN: HealthDataUnit.MILLISECOND,
      },
      startTime: start,
      endTime: end,
    );
    _debugLog(
      '${type.name}: ${points.length} samples entre '
      '${start.toIso8601String()} e ${end.toIso8601String()}.',
    );
    for (final point in points.take(5)) {
      _debugLog(
        '${type.name} sample: from=${point.dateFrom.toIso8601String()} '
        'to=${point.dateTo.toIso8601String()} value=${_numericValue(point) ?? 'não numérico'} '
        'source=${point.sourceName}.',
      );
    }
    return points;
  }

  HealthDataPoint? _latestFromPoints(List<HealthDataPoint> points) {
    if (points.isEmpty) {
      return null;
    }

    final sortedPoints = List<HealthDataPoint>.of(points)
      ..sort((a, b) => b.dateTo.compareTo(a.dateTo));
    return sortedPoints.first;
  }

  num? _numericValue(HealthDataPoint? point) {
    final value = point?.value;
    if (value is! NumericHealthValue) {
      return null;
    }

    return value.numericValue;
  }

  DateTime _latestTimestamp(
    HealthDataPoint heartRatePoint,
    HealthDataPoint? hrvPoint,
  ) {
    final hrvDate = hrvPoint?.dateTo;
    if (hrvDate != null && hrvDate.isAfter(heartRatePoint.dateTo)) {
      return hrvDate;
    }

    return heartRatePoint.dateTo;
  }

  ({DateTime start, DateTime end}) _debugWindow() {
    final end = DateTime.now();
    return (start: end.subtract(_diagnosticWindow), end: end);
  }

  void _debugLog(String message) {
    developer.log(message, name: 'HealthKitSensorProvider');
  }
}

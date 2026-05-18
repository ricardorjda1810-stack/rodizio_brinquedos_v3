import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/sensor_reliability/reliability_score_service.dart';
import 'package:signalflow/sensor_reliability/sensor_comparison_service.dart';
import 'package:signalflow/sensor_reliability/sensor_divergence_detector.dart';
import 'package:signalflow/sensor_reliability/sensor_reliability_models.dart';

void main() {
  group('SensorComparisonService', () {
    final start = DateTime.utc(2026, 5, 18, 12);
    late List<SensorReading> reference;
    late List<SensorReading> primary;

    setUp(() {
      reference = [
        SensorReading(
          sensorType: 'Polar H10',
          timestamp: start,
          heartRate: 72,
          hrv: 42,
          confidence: 94,
        ),
        SensorReading(
          sensorType: 'Polar H10',
          timestamp: start.add(const Duration(seconds: 10)),
          heartRate: 74,
          hrv: 40,
          confidence: 94,
        ),
      ];
      primary = [
        SensorReading(
          sensorType: 'Apple Health',
          timestamp: start.add(const Duration(milliseconds: 250)),
          heartRate: 73,
          hrv: 41,
          confidence: 88,
        ),
        SensorReading(
          sensorType: 'Apple Health',
          timestamp: start.add(const Duration(seconds: 10, milliseconds: 300)),
          heartRate: 76,
          hrv: 39,
          confidence: 87,
        ),
      ];
    });

    test('compares HR and HRV agreement', () {
      const service = SensorComparisonService();

      expect(service.compareHeartRate(primary, reference), greaterThan(98));
      expect(service.compareHrv(primary, reference), greaterThan(98));
    });

    test('calculates temporal drift and comparison result', () {
      final service = SensorComparisonService(
        now: () => DateTime.utc(2026, 5, 18, 12, 1),
      );

      final result = service.compareSensors(
        primarySensor: 'Apple Health',
        referenceSensor: 'Polar H10',
        primaryReadings: primary,
        referenceReadings: reference,
      );

      expect(result.averageDriftMs, closeTo(275, 1));
      expect(result.timingAgreement, greaterThan(85));
      expect(result.safetyCopy, contains('comparação técnica de sinais'));
    });

    test('detects divergences', () {
      final divergent = [
        SensorReading(
          sensorType: 'Apple Health',
          timestamp: start.add(const Duration(seconds: 3)),
          heartRate: 95,
          hrv: 20,
          confidence: 50,
          missingData: true,
        ),
      ];
      const detector = SensorDivergenceDetector();

      final factors = detector.detectDivergences(
        primaryReadings: divergent,
        referenceReadings: [reference.first],
      );

      expect(factors, contains('divergência HR na comparação de sinais.'));
      expect(factors, contains('divergência HRV na comparação de sinais.'));
      expect(factors, contains('drift temporal entre sensores.'));
      expect(factors, contains('perda de sinal observada.'));
    });

    test('calculates reliability score with penalties and bonus', () {
      const scoreService = ReliabilityScoreService();

      final highScore = scoreService.calculateReliabilityScore(
        averageConfidence: 92,
        artifactRate: 0,
        missingDataRate: 0,
        timingDriftMs: 100,
        agreementWithReference: 94,
      );
      final lowScore = scoreService.calculateReliabilityScore(
        averageConfidence: 60,
        artifactRate: 30,
        missingDataRate: 20,
        timingDriftMs: 3000,
        agreementWithReference: 55,
      );

      expect(highScore, greaterThan(lowScore));
      expect(highScore, inInclusiveRange(0, 100));
      expect(lowScore, inInclusiveRange(0, 100));
    });
  });
}

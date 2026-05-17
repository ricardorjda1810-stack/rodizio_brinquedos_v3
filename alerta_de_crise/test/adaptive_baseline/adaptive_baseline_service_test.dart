import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/adaptive_baseline/adaptive_baseline_service.dart';
import 'package:signalflow/adaptive_baseline/adaptive_baseline_statistics.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/database/signalflow_database.dart';

void main() {
  group('AdaptiveBaselineService', () {
    late SignalFlowDatabase database;
    late DateTime now;
    late AdaptiveBaselineService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      now = DateTime.utc(2026, 5, 17, 12);
      service = AdaptiveBaselineService(database: database, now: () => now);
    });

    tearDown(() async {
      await database.close();
    });

    test('creates circadian profiles from historical samples', () {
      final baseline = service.buildAdaptiveBaseline(samples: _samples());

      expect(baseline.totalSamples, _samples().length);
      expect(baseline.circadianProfiles.length, greaterThanOrEqualTo(4));
      expect(
        baseline.circadianProfiles.map((profile) => profile.window.label),
        containsAll(['earlyMorning', 'morning', 'afternoon', 'evening']),
      );
    });

    test('averages are consistent for each profile', () {
      final baseline = service.buildAdaptiveBaseline(samples: _samples());
      final morning = baseline.circadianProfiles.firstWhere(
        (profile) => profile.window.label == 'morning',
      );

      expect(morning.averageHeartRate, 73);
      expect(morning.averageHrv, 41.5);
      expect(morning.sampleCount, 2);
    });

    test('returns profile for current timestamp', () {
      final baseline = service.buildAdaptiveBaseline(samples: _samples());
      final profile = service.getCurrentCircadianProfile(
        baseline: baseline,
        timestamp: DateTime.utc(2026, 5, 17, 20),
      );

      expect(profile?.window.label, 'evening');
    });

    test('updates gradually and avoids abrupt baseline shifts', () {
      final baseline = service.buildAdaptiveBaseline(samples: _samples());
      final updated = service.updateWithNewSample(
        current: baseline,
        sample: _sample(hour: 10, heartRate: 150, hrv: 20),
      );

      expect(
        updated.globalBaseline.restingHeartRateBpm -
            baseline.globalBaseline.restingHeartRateBpm,
        lessThan(15),
      );
      expect(updated.totalSamples, baseline.totalSamples + 1);
    });

    test('statistics calculate stability and trend', () {
      final statistics = AdaptiveBaselineStatistics.fromSamples(_samples());

      expect(statistics.stabilityScore, greaterThan(80));
      expect(statistics.heartRateStandardDeviation, greaterThan(0));
      expect(statistics.heartRateTrend, isNonZero);
    });

    test('persists and loads adaptive baseline', () async {
      final baseline = service.buildAdaptiveBaseline(samples: _samples());

      await service.saveAdaptiveBaseline(baseline);
      final loaded = await service.loadAdaptiveBaseline();

      expect(loaded, isNotNull);
      expect(loaded?.totalSamples, baseline.totalSamples);
      expect(
        loaded?.circadianProfiles.length,
        baseline.circadianProfiles.length,
      );
      expect(
        loaded?.globalBaseline.restingHeartRateBpm,
        baseline.globalBaseline.restingHeartRateBpm,
      );
    });
  });
}

List<PhysiologicalSample> _samples() {
  return [
    _sample(hour: 6, heartRate: 66, hrv: 48),
    _sample(hour: 7, heartRate: 68, hrv: 46),
    _sample(hour: 9, heartRate: 72, hrv: 42),
    _sample(hour: 10, heartRate: 74, hrv: 41),
    _sample(hour: 14, heartRate: 78, hrv: 38),
    _sample(hour: 15, heartRate: 80, hrv: 37),
    _sample(hour: 19, heartRate: 82, hrv: 36),
    _sample(hour: 20, heartRate: 84, hrv: 35),
    _sample(hour: 23, heartRate: 70, hrv: 44),
    _sample(hour: 2, heartRate: 62, hrv: 52),
  ];
}

PhysiologicalSample _sample({
  required int hour,
  required double heartRate,
  required double hrv,
}) {
  return PhysiologicalSample(
    timestamp: DateTime.utc(2026, 5, 17, hour),
    heartRateBpm: heartRate,
    hrvRmssdMs: hrv,
    respiratoryRate: 16,
    movementIntensity: 0.15,
  );
}

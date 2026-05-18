import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/calibration_lab/calibration_profile.dart';
import 'package:signalflow/calibration_lab/threshold_tuning_service.dart';

void main() {
  group('ThresholdTuningService', () {
    const service = ThresholdTuningService();

    test('presets are valid', () {
      final presets = CalibrationProfiles.presets();

      expect(presets, hasLength(4));
      expect(presets.map((profile) => profile.id), contains('balanced'));
      for (final profile in presets) {
        final applied = service.applyProfile(profile);
        expect(applied.escalationThreshold, inInclusiveRange(0, 100));
        expect(applied.recoveryThreshold, inInclusiveRange(0, 100));
        expect(applied.safetyCopy, contains('calibração experimental'));
      }
    });

    test('normalizes weights', () {
      final normalized = service.normalizeWeights({
        'confidence': 2,
        'fusion': 1,
      });

      expect(normalized['confidence'], closeTo(0.666, 0.01));
      expect(normalized['fusion'], closeTo(0.333, 0.01));
    });

    test('compares profiles and generates variants', () {
      final variants = service.generateVariants(CalibrationProfiles.balanced);
      final comparisons = service.compareThresholds(
        baseline: CalibrationProfiles.balanced,
        candidate: CalibrationProfiles.aggressive,
      );

      expect(variants, hasLength(3));
      expect(comparisons, hasLength(4));
      expect(
        comparisons.first.interpretation,
        contains('calibração experimental'),
      );
    });
  });
}

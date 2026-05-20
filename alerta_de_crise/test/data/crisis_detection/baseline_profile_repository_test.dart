import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/data/crisis_detection/baseline_profile_repository.dart';

void main() {
  group('BaselineProfileRepository', () {
    test('save and getCurrent works', () {
      final repository = BaselineProfileRepository();
      final baseline = BaselineProfile.safeDefault();

      repository.save(baseline);

      expect(repository.getCurrent(), baseline);
    });

    test('clear removes baseline', () {
      final repository = BaselineProfileRepository();

      repository
        ..save(BaselineProfile.safeDefault())
        ..clear();

      expect(repository.getCurrent(), isNull);
    });

    test('overwrites previous baseline', () {
      final repository = BaselineProfileRepository();
      final first = BaselineProfile.safeDefault();
      const second = BaselineProfile(
        restingHeartRateBpm: 68,
        hrvRmssdMs: 50,
        respiratoryRate: 15,
        movementIntensity: 0.1,
      );

      repository
        ..save(first)
        ..save(second);

      expect(repository.getCurrent(), second);
    });
  });
}

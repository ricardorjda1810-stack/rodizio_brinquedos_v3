import 'package:drift/drift.dart';

import '../core/crisis_detection/baseline_builder.dart';
import '../core/crisis_detection/baseline_profile.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../database/signalflow_database.dart';
import 'adaptive_baseline_models.dart';
import 'adaptive_baseline_statistics.dart';
import 'circadian_profile.dart';
import 'circadian_window.dart';

class AdaptiveBaselineService {
  static const _baselineId = 'adaptive-current';
  static const _smoothingFactor = 0.15;

  final BaselineBuilder _baselineBuilder;
  final SignalFlowDatabase? _database;
  final DateTime Function() _now;

  AdaptiveBaselineService({
    BaselineBuilder baselineBuilder = const BaselineBuilder(),
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _baselineBuilder = baselineBuilder,
       _database = database,
       _now = now ?? DateTime.now;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  AdaptiveBaselineProfile buildAdaptiveBaseline({
    required List<PhysiologicalSample> samples,
  }) {
    final timestamp = _now();
    final globalBaseline = _baselineBuilder.build(samples);
    final grouped = AdaptiveBaselineStatistics.groupByWindow(samples);
    final profiles = <CircadianProfile>[];

    for (final entry in grouped.entries) {
      final profile = AdaptiveBaselineStatistics.buildProfileForWindow(
        entry.key,
        entry.value,
        updatedAt: timestamp,
      );
      if (profile != null) {
        profiles.add(profile);
      }
    }

    return AdaptiveBaselineProfile(
      globalBaseline: globalBaseline,
      circadianProfiles: List.unmodifiable(profiles),
      createdAt: timestamp,
      updatedAt: timestamp,
      totalSamples: samples.length,
    );
  }

  CircadianProfile? getCurrentCircadianProfile({
    required AdaptiveBaselineProfile baseline,
    required DateTime timestamp,
  }) {
    final window = CircadianWindow.forTimestamp(timestamp);
    for (final profile in baseline.circadianProfiles) {
      if (profile.window.label == window.label) {
        return profile;
      }
    }

    return null;
  }

  AdaptiveBaselineProfile updateWithNewSample({
    required AdaptiveBaselineProfile current,
    required PhysiologicalSample sample,
  }) {
    final updatedAt = _now();
    final updatedGlobal = BaselineProfile(
      restingHeartRateBpm: _smooth(
        current.globalBaseline.restingHeartRateBpm,
        sample.heartRateBpm,
      ),
      hrvRmssdMs: sample.hrvRmssdMs == null
          ? current.globalBaseline.hrvRmssdMs
          : _smooth(current.globalBaseline.hrvRmssdMs, sample.hrvRmssdMs!),
      respiratoryRate: sample.respiratoryRate == null
          ? current.globalBaseline.respiratoryRate
          : _smooth(
              current.globalBaseline.respiratoryRate,
              sample.respiratoryRate!,
            ),
      movementIntensity: _smooth(
        current.globalBaseline.movementIntensity,
        sample.movementIntensity,
      ),
    );

    final updatedProfiles = [...current.circadianProfiles];
    final window = CircadianWindow.forTimestamp(sample.timestamp);
    final profileIndex = updatedProfiles.indexWhere(
      (profile) => profile.window.label == window.label,
    );

    final existingProfile = profileIndex == -1
        ? null
        : updatedProfiles[profileIndex];
    final nextProfile = _updateCircadianProfile(
      existingProfile: existingProfile,
      window: window,
      sample: sample,
      updatedAt: updatedAt,
    );
    if (profileIndex == -1) {
      updatedProfiles.add(nextProfile);
    } else {
      updatedProfiles[profileIndex] = nextProfile;
    }

    return AdaptiveBaselineProfile(
      globalBaseline: updatedGlobal,
      circadianProfiles: List.unmodifiable(updatedProfiles),
      createdAt: current.createdAt,
      updatedAt: updatedAt,
      totalSamples: current.totalSamples + 1,
    );
  }

  Future<void> saveAdaptiveBaseline(AdaptiveBaselineProfile baseline) async {
    await _db.transaction(() async {
      await _db
          .into(_db.adaptiveBaselineStateTable)
          .insertOnConflictUpdate(
            AdaptiveBaselineStateTableCompanion.insert(
              id: _baselineId,
              createdAt: baseline.createdAt,
              updatedAt: baseline.updatedAt,
              totalSamples: baseline.totalSamples,
              restingHeartRate: baseline.globalBaseline.restingHeartRateBpm,
              hrvRmssd: baseline.globalBaseline.hrvRmssdMs,
              respiratoryRate: baseline.globalBaseline.respiratoryRate,
              movementIntensity: baseline.globalBaseline.movementIntensity,
            ),
          );
      await (_db.delete(
        _db.circadianProfilesTable,
      )..where((table) => table.baselineId.equals(_baselineId))).go();
      for (final profile in baseline.circadianProfiles) {
        await _db
            .into(_db.circadianProfilesTable)
            .insert(
              CircadianProfilesTableCompanion.insert(
                id: '$_baselineId-${profile.window.label}',
                baselineId: _baselineId,
                windowLabel: profile.window.label,
                startHour: profile.window.startHour,
                endHour: profile.window.endHour,
                averageHeartRate: profile.averageHeartRate,
                averageHrv: Value(profile.averageHrv),
                averageRespiratoryRate: Value(profile.averageRespiratoryRate),
                sampleCount: profile.sampleCount,
                updatedAt: profile.updatedAt,
              ),
            );
      }
    });
  }

  Future<AdaptiveBaselineProfile?> loadAdaptiveBaseline() async {
    final state = await (_db.select(
      _db.adaptiveBaselineStateTable,
    )..where((table) => table.id.equals(_baselineId))).getSingleOrNull();
    if (state == null) {
      return null;
    }

    final profileRows = await (_db.select(
      _db.circadianProfilesTable,
    )..where((table) => table.baselineId.equals(_baselineId))).get();

    return AdaptiveBaselineProfile(
      globalBaseline: BaselineProfile(
        restingHeartRateBpm: state.restingHeartRate,
        hrvRmssdMs: state.hrvRmssd,
        respiratoryRate: state.respiratoryRate,
        movementIntensity: state.movementIntensity,
      ),
      circadianProfiles: List.unmodifiable(profileRows.map(_profileFromRow)),
      createdAt: state.createdAt,
      updatedAt: state.updatedAt,
      totalSamples: state.totalSamples,
    );
  }

  CircadianProfile _updateCircadianProfile({
    required CircadianProfile? existingProfile,
    required CircadianWindow window,
    required PhysiologicalSample sample,
    required DateTime updatedAt,
  }) {
    if (existingProfile == null) {
      return CircadianProfile(
        window: window,
        averageHeartRate: sample.heartRateBpm,
        averageHrv: sample.hrvRmssdMs,
        averageRespiratoryRate: sample.respiratoryRate,
        sampleCount: 1,
        updatedAt: updatedAt,
      );
    }

    return CircadianProfile(
      window: existingProfile.window,
      averageHeartRate: _smooth(
        existingProfile.averageHeartRate,
        sample.heartRateBpm,
      ),
      averageHrv: _smoothNullable(
        existingProfile.averageHrv,
        sample.hrvRmssdMs,
      ),
      averageRespiratoryRate: _smoothNullable(
        existingProfile.averageRespiratoryRate,
        sample.respiratoryRate,
      ),
      sampleCount: existingProfile.sampleCount + 1,
      updatedAt: updatedAt,
    );
  }

  CircadianProfile _profileFromRow(CircadianProfilesTableData row) {
    return CircadianProfile(
      window: CircadianWindow(
        startHour: row.startHour,
        endHour: row.endHour,
        label: row.windowLabel,
      ),
      averageHeartRate: row.averageHeartRate,
      averageHrv: row.averageHrv,
      averageRespiratoryRate: row.averageRespiratoryRate,
      sampleCount: row.sampleCount,
      updatedAt: row.updatedAt,
    );
  }

  double _smooth(double current, double next) {
    return current + (next - current) * _smoothingFactor;
  }

  double? _smoothNullable(double? current, double? next) {
    if (next == null) {
      return current;
    }
    if (current == null) {
      return next;
    }

    return _smooth(current, next);
  }
}

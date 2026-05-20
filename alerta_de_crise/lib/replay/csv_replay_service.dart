import '../core/crisis_detection/baseline_builder.dart';
import '../core/crisis_detection/crisis_detection_service.dart';
import '../core/crisis_detection/physiological_sample.dart';
import 'csv_replay_session.dart';
import 'csv_replay_statistics.dart';

typedef CsvReplayClock = DateTime Function();

class CsvReplayService {
  final BaselineBuilder _baselineBuilder;
  final CrisisDetectionService _detectionService;
  final CsvReplayClock _clock;

  const CsvReplayService({
    required CrisisDetectionService detectionService,
    BaselineBuilder baselineBuilder = const BaselineBuilder(),
    CsvReplayClock? clock,
  }) : _detectionService = detectionService,
       _baselineBuilder = baselineBuilder,
       _clock = clock ?? DateTime.now;

  CsvReplaySession runReplay({required List<PhysiologicalSample> samples}) {
    final createdAt = _clock();
    if (samples.isEmpty) {
      final statistics = CsvReplayStatistics.empty();
      return CsvReplaySession(
        id: 'csv-replay-${createdAt.microsecondsSinceEpoch}',
        createdAt: createdAt,
        totalSamples: 0,
        processedSamples: 0,
        startedAt: null,
        completedAt: createdAt,
        averageScore: statistics.averageScore,
        highestScore: statistics.highestScore,
        highInterventionCount: statistics.highInterventionCount,
        statistics: statistics,
      );
    }

    final baseline = _baselineBuilder.build(samples);
    final results = samples
        .map(
          (sample) => _detectionService.evaluateAndRecord(
            sample: sample,
            baseline: baseline,
            source: 'csvReplay',
          ),
        )
        .toList(growable: false);
    final statistics = CsvReplayStatistics.fromResults(
      samples: samples,
      results: results,
    );

    return CsvReplaySession(
      id: 'csv-replay-${createdAt.microsecondsSinceEpoch}',
      createdAt: createdAt,
      totalSamples: samples.length,
      processedSamples: results.length,
      startedAt: samples.first.timestamp,
      completedAt: samples.last.timestamp,
      averageScore: statistics.averageScore,
      highestScore: statistics.highestScore,
      highInterventionCount: statistics.highInterventionCount,
      statistics: statistics,
    );
  }
}

import '../core/crisis_detection/physiological_sample.dart';

enum RealtimeStreamingState { stopped, running, paused }

class RollingWindow {
  final Duration duration;
  final List<PhysiologicalSample> samples;
  final DateTime generatedAt;

  const RollingWindow({
    required this.duration,
    required this.samples,
    required this.generatedAt,
  });

  static const ultraShortDuration = Duration(seconds: 30);
  static const shortDuration = Duration(minutes: 5);
  static const mediumDuration = Duration(minutes: 30);
  static const longDuration = Duration(hours: 2);

  static RollingWindow ultraShort({
    required List<PhysiologicalSample> samples,
    required DateTime generatedAt,
  }) {
    return RollingWindow(
      duration: ultraShortDuration,
      samples: samples,
      generatedAt: generatedAt,
    );
  }

  static RollingWindow short({
    required List<PhysiologicalSample> samples,
    required DateTime generatedAt,
  }) {
    return RollingWindow(
      duration: shortDuration,
      samples: samples,
      generatedAt: generatedAt,
    );
  }

  static RollingWindow medium({
    required List<PhysiologicalSample> samples,
    required DateTime generatedAt,
  }) {
    return RollingWindow(
      duration: mediumDuration,
      samples: samples,
      generatedAt: generatedAt,
    );
  }

  static RollingWindow long({
    required List<PhysiologicalSample> samples,
    required DateTime generatedAt,
  }) {
    return RollingWindow(
      duration: longDuration,
      samples: samples,
      generatedAt: generatedAt,
    );
  }
}

class RollingMetrics {
  final double averageHeartRate;
  final double averageHrv;
  final double confidence;
  final double escalationDensity;
  final int sampleCount;

  const RollingMetrics({
    required this.averageHeartRate,
    required this.averageHrv,
    required this.confidence,
    required this.escalationDensity,
    required this.sampleCount,
  });
}

class RealtimePipelineSnapshot {
  final String id;
  final DateTime generatedAt;
  final int bufferSize;
  final double rollingHeartRate;
  final double rollingHrv;
  final double rollingConfidence;
  final double rollingEscalationDensity;
  final double latestEscalationProbability;
  final RealtimeStreamingState streamingState;

  const RealtimePipelineSnapshot({
    required this.id,
    required this.generatedAt,
    required this.bufferSize,
    required this.rollingHeartRate,
    required this.rollingHrv,
    required this.rollingConfidence,
    required this.rollingEscalationDensity,
    required this.latestEscalationProbability,
    required this.streamingState,
  });

  String get safetyCopy =>
      'streaming experimental para pesquisa/autoconhecimento; não monitoramento médico contínuo.';
}

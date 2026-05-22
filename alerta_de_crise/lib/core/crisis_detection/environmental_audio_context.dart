class EnvironmentalAudioThresholds {
  final double elevatedNoiseDb;
  final double highNoiseDb;
  final double veryHighNoiseDb;
  final Duration lookbackWindow;
  final Duration lookaheadWindow;
  final int elevatedNoiseStressWeight;
  final int highNoiseStressWeight;
  final int veryHighNoiseStressWeight;

  const EnvironmentalAudioThresholds({
    this.elevatedNoiseDb = 80.0,
    this.highNoiseDb = 85.0,
    this.veryHighNoiseDb = 90.0,
    this.lookbackWindow = const Duration(minutes: 3),
    this.lookaheadWindow = const Duration(minutes: 1),
    this.elevatedNoiseStressWeight = 1,
    this.highNoiseStressWeight = 1,
    this.veryHighNoiseStressWeight = 2,
  });
}

enum EnvironmentalContext { none, elevatedNoise, highNoise, veryHighNoise }

class EnvironmentalAudioSample {
  final DateTime timestamp;
  final double decibels;

  const EnvironmentalAudioSample({
    required this.timestamp,
    required this.decibels,
  });
}

class EnvironmentalAudioContext {
  final EnvironmentalContext context;
  final double? peakDecibels;
  final DateTime? peakTimestamp;
  final EnvironmentalAudioThresholds thresholds;

  const EnvironmentalAudioContext({
    required this.context,
    this.peakDecibels,
    this.peakTimestamp,
    this.thresholds = const EnvironmentalAudioThresholds(),
  });

  const EnvironmentalAudioContext.none({
    this.thresholds = const EnvironmentalAudioThresholds(),
  }) : context = EnvironmentalContext.none,
       peakDecibels = null,
       peakTimestamp = null;

  factory EnvironmentalAudioContext.fromSamples({
    required DateTime eventTimestamp,
    required List<EnvironmentalAudioSample> samples,
    EnvironmentalAudioThresholds thresholds =
        const EnvironmentalAudioThresholds(),
  }) {
    final windowStart = eventTimestamp.subtract(thresholds.lookbackWindow);
    final windowEnd = eventTimestamp.add(thresholds.lookaheadWindow);
    final nearbySamples = samples.where((sample) {
      return !sample.timestamp.isBefore(windowStart) &&
          !sample.timestamp.isAfter(windowEnd);
    }).toList();

    if (nearbySamples.isEmpty) {
      return EnvironmentalAudioContext.none(thresholds: thresholds);
    }

    nearbySamples.sort((a, b) => b.decibels.compareTo(a.decibels));
    final peak = nearbySamples.first;

    return EnvironmentalAudioContext(
      context: _contextFor(peak.decibels, thresholds),
      peakDecibels: peak.decibels,
      peakTimestamp: peak.timestamp,
      thresholds: thresholds,
    );
  }

  bool get hasNoise => context != EnvironmentalContext.none;

  int get stressWeight {
    return switch (context) {
      EnvironmentalContext.none => 0,
      EnvironmentalContext.elevatedNoise =>
        thresholds.elevatedNoiseStressWeight,
      EnvironmentalContext.highNoise => thresholds.highNoiseStressWeight,
      EnvironmentalContext.veryHighNoise =>
        thresholds.veryHighNoiseStressWeight,
    };
  }

  static EnvironmentalContext _contextFor(
    double decibels,
    EnvironmentalAudioThresholds thresholds,
  ) {
    if (decibels >= thresholds.veryHighNoiseDb) {
      return EnvironmentalContext.veryHighNoise;
    }
    if (decibels >= thresholds.highNoiseDb) {
      return EnvironmentalContext.highNoise;
    }
    if (decibels >= thresholds.elevatedNoiseDb) {
      return EnvironmentalContext.elevatedNoise;
    }
    return EnvironmentalContext.none;
  }
}

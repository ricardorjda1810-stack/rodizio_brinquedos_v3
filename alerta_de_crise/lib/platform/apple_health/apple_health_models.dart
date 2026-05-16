enum AppleHealthMetric { heartRate, hrvSdnn, spo2 }

class AppleHealthQuantitySample {
  final AppleHealthMetric metric;
  final double value;
  final DateTime timestamp;
  final String sourceName;

  const AppleHealthQuantitySample({
    required this.metric,
    required this.value,
    required this.timestamp,
    this.sourceName = 'Apple Health',
  });

  double get normalizedValue {
    if (metric == AppleHealthMetric.spo2 && value > 0 && value <= 1) {
      return value * 100;
    }

    return value;
  }

  bool get isValid {
    return switch (metric) {
      AppleHealthMetric.heartRate =>
        normalizedValue >= 35 && normalizedValue <= 220,
      AppleHealthMetric.hrvSdnn => normalizedValue > 0 && normalizedValue < 250,
      AppleHealthMetric.spo2 => normalizedValue >= 50 && normalizedValue <= 100,
    };
  }
}

class AppleHealthReading {
  final AppleHealthQuantitySample? heartRate;
  final AppleHealthQuantitySample? hrv;
  final AppleHealthQuantitySample? spo2;

  const AppleHealthReading({this.heartRate, this.hrv, this.spo2});

  bool get hasHeartRate => heartRate != null;

  DateTime? get latestTimestamp {
    final timestamps = [
      heartRate?.timestamp,
      hrv?.timestamp,
      spo2?.timestamp,
    ].nonNulls.toList();

    if (timestamps.isEmpty) {
      return null;
    }

    timestamps.sort((a, b) => b.compareTo(a));
    return timestamps.first;
  }
}

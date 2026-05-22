class PolarH10AccelerometerSample {
  final DateTime timestamp;
  final DateTime receivedAt;
  final int xMg;
  final int yMg;
  final int zMg;

  const PolarH10AccelerometerSample({
    required this.timestamp,
    required this.receivedAt,
    required this.xMg,
    required this.yMg,
    required this.zMg,
  });
}

class PolarH10MotionThresholds {
  static const double stillnessRmsMg = 35;
  static const double lightMotionRmsMg = 80;
  static const double moderateMotionRmsMg = 180;
  static const double strongMotionRmsMg = 350;

  const PolarH10MotionThresholds._();
}

enum PolarH10MotionClass {
  unavailable,
  still,
  light,
  moderate,
  high;

  String get label {
    return switch (this) {
      PolarH10MotionClass.unavailable => 'Movimento H10 indisponível',
      PolarH10MotionClass.still => 'parado',
      PolarH10MotionClass.light => 'movimento leve',
      PolarH10MotionClass.moderate => 'movimento moderado',
      PolarH10MotionClass.high => 'movimento alto',
    };
  }

  double get intensity {
    return switch (this) {
      PolarH10MotionClass.unavailable => 0.5,
      PolarH10MotionClass.still => 0.1,
      PolarH10MotionClass.light => 0.3,
      PolarH10MotionClass.moderate => 0.6,
      PolarH10MotionClass.high => 0.9,
    };
  }
}

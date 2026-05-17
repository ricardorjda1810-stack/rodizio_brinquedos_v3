import 'circadian_window.dart';

class CircadianProfile {
  final CircadianWindow window;
  final double averageHeartRate;
  final double? averageHrv;
  final double? averageRespiratoryRate;
  final int sampleCount;
  final DateTime updatedAt;

  const CircadianProfile({
    required this.window,
    required this.averageHeartRate,
    required this.averageHrv,
    required this.averageRespiratoryRate,
    required this.sampleCount,
    required this.updatedAt,
  });
}

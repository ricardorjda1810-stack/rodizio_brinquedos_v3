class SessionTimeline {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalSamples;
  final int totalEvents;
  final double? averageHeartRate;
  final double? averageHrv;
  final double? maxHeartRate;
  final double? minHrv;

  const SessionTimeline({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.totalSamples,
    required this.totalEvents,
    required this.averageHeartRate,
    required this.averageHrv,
    required this.maxHeartRate,
    required this.minHrv,
  });

  bool get isActive => endedAt == null;
}

class CircadianWindow {
  final int startHour;
  final int endHour;
  final String label;

  const CircadianWindow({
    required this.startHour,
    required this.endHour,
    required this.label,
  }) : assert(startHour >= 0 && startHour <= 23),
       assert(endHour >= 0 && endHour <= 23);

  static const earlyMorning = CircadianWindow(
    startHour: 5,
    endHour: 8,
    label: 'earlyMorning',
  );
  static const morning = CircadianWindow(
    startHour: 9,
    endHour: 11,
    label: 'morning',
  );
  static const afternoon = CircadianWindow(
    startHour: 12,
    endHour: 17,
    label: 'afternoon',
  );
  static const evening = CircadianWindow(
    startHour: 18,
    endHour: 21,
    label: 'evening',
  );
  static const night = CircadianWindow(
    startHour: 22,
    endHour: 4,
    label: 'night',
  );

  static const defaults = [earlyMorning, morning, afternoon, evening, night];

  bool contains(DateTime timestamp) {
    final hour = timestamp.hour;
    if (startHour <= endHour) {
      return hour >= startHour && hour <= endHour;
    }

    return hour >= startHour || hour <= endHour;
  }

  static CircadianWindow forTimestamp(DateTime timestamp) {
    return defaults.firstWhere((window) => window.contains(timestamp));
  }
}

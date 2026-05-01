class WeekDaySummary {
  final int weekday;
  final String shortLabel;
  final String fullLabel;
  final int totalToys;
  final bool usesDefault;
  final bool isToday;

  const WeekDaySummary({
    required this.weekday,
    required this.shortLabel,
    required this.fullLabel,
    required this.totalToys,
    required this.usesDefault,
    required this.isToday,
  });
}

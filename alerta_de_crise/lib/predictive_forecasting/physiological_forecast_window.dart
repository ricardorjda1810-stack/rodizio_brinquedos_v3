class PhysiologicalForecastWindow {
  final Duration duration;
  final String label;

  const PhysiologicalForecastWindow({
    required this.duration,
    required this.label,
  });

  static const immediate = PhysiologicalForecastWindow(
    duration: Duration(minutes: 5),
    label: '5 min',
  );

  static const nearFuture = PhysiologicalForecastWindow(
    duration: Duration(minutes: 15),
    label: '15 min',
  );

  static const extended = PhysiologicalForecastWindow(
    duration: Duration(minutes: 60),
    label: '60 min',
  );
}

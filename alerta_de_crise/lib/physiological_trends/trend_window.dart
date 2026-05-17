class TrendWindow {
  final Duration duration;
  final String label;

  const TrendWindow({required this.duration, required this.label});

  static const shortTerm = TrendWindow(
    duration: Duration(minutes: 5),
    label: 'shortTerm',
  );

  static const mediumTerm = TrendWindow(
    duration: Duration(minutes: 30),
    label: 'mediumTerm',
  );

  static const longTerm = TrendWindow(
    duration: Duration(hours: 2),
    label: 'longTerm',
  );

  static const defaults = [shortTerm, mediumTerm, longTerm];
}

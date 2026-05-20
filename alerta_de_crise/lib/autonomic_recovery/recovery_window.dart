class RecoveryWindow {
  final Duration duration;
  final String label;

  const RecoveryWindow({required this.duration, required this.label});

  static const immediate = RecoveryWindow(
    duration: Duration(minutes: 5),
    label: 'immediate',
  );

  static const shortRecovery = RecoveryWindow(
    duration: Duration(minutes: 30),
    label: 'shortRecovery',
  );

  static const prolongedRecovery = RecoveryWindow(
    duration: Duration(hours: 6),
    label: 'prolongedRecovery',
  );

  static const defaults = [immediate, shortRecovery, prolongedRecovery];
}

class PerceivedState {
  final DateTime timestamp;
  final int perceivedStress;
  final int perceivedFatigue;
  final int perceivedControl;
  final int perceivedRecovery;
  final int emotionalIntensity;
  final String notes;

  const PerceivedState({
    required this.timestamp,
    required this.perceivedStress,
    required this.perceivedFatigue,
    required this.perceivedControl,
    required this.perceivedRecovery,
    required this.emotionalIntensity,
    this.notes = '',
  });

  PerceivedState normalized() {
    return PerceivedState(
      timestamp: timestamp,
      perceivedStress: _clampScale(perceivedStress),
      perceivedFatigue: _clampScale(perceivedFatigue),
      perceivedControl: _clampScale(perceivedControl),
      perceivedRecovery: _clampScale(perceivedRecovery),
      emotionalIntensity: _clampScale(emotionalIntensity),
      notes: notes,
    );
  }

  int get perceivedLoad =>
      ((perceivedStress + perceivedFatigue + emotionalIntensity) / 3).round();

  static int _clampScale(int value) => value.clamp(0, 10).toInt();
}

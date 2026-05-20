class CalibrationProfile {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final double heartRateSensitivity;
  final double hrvSuppressionSensitivity;
  final double recoverySensitivity;
  final double forecastSensitivity;
  final double confidenceWeight;
  final double fusionWeight;
  final double escalationThreshold;
  final double recoveryThreshold;

  const CalibrationProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.heartRateSensitivity,
    required this.hrvSuppressionSensitivity,
    required this.recoverySensitivity,
    required this.forecastSensitivity,
    required this.confidenceWeight,
    required this.fusionWeight,
    required this.escalationThreshold,
    required this.recoveryThreshold,
  });

  CalibrationProfile copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    double? heartRateSensitivity,
    double? hrvSuppressionSensitivity,
    double? recoverySensitivity,
    double? forecastSensitivity,
    double? confidenceWeight,
    double? fusionWeight,
    double? escalationThreshold,
    double? recoveryThreshold,
  }) {
    return CalibrationProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      heartRateSensitivity: heartRateSensitivity ?? this.heartRateSensitivity,
      hrvSuppressionSensitivity:
          hrvSuppressionSensitivity ?? this.hrvSuppressionSensitivity,
      recoverySensitivity: recoverySensitivity ?? this.recoverySensitivity,
      forecastSensitivity: forecastSensitivity ?? this.forecastSensitivity,
      confidenceWeight: confidenceWeight ?? this.confidenceWeight,
      fusionWeight: fusionWeight ?? this.fusionWeight,
      escalationThreshold: escalationThreshold ?? this.escalationThreshold,
      recoveryThreshold: recoveryThreshold ?? this.recoveryThreshold,
    );
  }

  String get safetyCopy =>
      'calibração experimental; parâmetros usados apenas para pesquisa/autoconhecimento; não representa validação clínica.';
}

class CalibrationProfiles {
  static final DateTime _presetCreatedAt = DateTime.utc(2026, 5, 18);

  static List<CalibrationProfile> presets() {
    return [conservative, balanced, aggressive, recoveryFocused];
  }

  static final CalibrationProfile conservative = CalibrationProfile(
    id: 'conservative',
    name: 'Conservative',
    description:
        'calibração experimental com ajuste de parâmetros mais estável.',
    createdAt: _presetCreatedAt,
    heartRateSensitivity: 0.75,
    hrvSuppressionSensitivity: 0.72,
    recoverySensitivity: 0.78,
    forecastSensitivity: 0.7,
    confidenceWeight: 0.6,
    fusionWeight: 0.4,
    escalationThreshold: 72,
    recoveryThreshold: 64,
  );

  static final CalibrationProfile balanced = CalibrationProfile(
    id: 'balanced',
    name: 'Balanced',
    description:
        'calibração experimental balanceada para benchmark de thresholds.',
    createdAt: _presetCreatedAt,
    heartRateSensitivity: 0.9,
    hrvSuppressionSensitivity: 0.9,
    recoverySensitivity: 0.9,
    forecastSensitivity: 0.9,
    confidenceWeight: 0.5,
    fusionWeight: 0.5,
    escalationThreshold: 65,
    recoveryThreshold: 58,
  );

  static final CalibrationProfile aggressive = CalibrationProfile(
    id: 'aggressive',
    name: 'Aggressive',
    description:
        'calibração experimental mais sensível para comparação de configuração.',
    createdAt: _presetCreatedAt,
    heartRateSensitivity: 1.12,
    hrvSuppressionSensitivity: 1.08,
    recoverySensitivity: 0.86,
    forecastSensitivity: 1.14,
    confidenceWeight: 0.45,
    fusionWeight: 0.55,
    escalationThreshold: 55,
    recoveryThreshold: 52,
  );

  static final CalibrationProfile recoveryFocused = CalibrationProfile(
    id: 'recovery-focused',
    name: 'Recovery Focused',
    description:
        'calibração experimental focada em padrões de recuperação observados.',
    createdAt: _presetCreatedAt,
    heartRateSensitivity: 0.82,
    hrvSuppressionSensitivity: 0.88,
    recoverySensitivity: 1.16,
    forecastSensitivity: 0.82,
    confidenceWeight: 0.54,
    fusionWeight: 0.46,
    escalationThreshold: 68,
    recoveryThreshold: 62,
  );
}

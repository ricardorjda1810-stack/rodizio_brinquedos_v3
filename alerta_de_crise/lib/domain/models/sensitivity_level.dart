enum SensitivityLevel { baixa, media, alta }

extension SensitivityLevelText on SensitivityLevel {
  static SensitivityLevel fromKey(String key) {
    return SensitivityLevel.values.firstWhere(
      (level) => level.key == key,
      orElse: () => SensitivityLevel.media,
    );
  }

  String get key {
    return switch (this) {
      SensitivityLevel.baixa => 'baixa',
      SensitivityLevel.media => 'media',
      SensitivityLevel.alta => 'alta',
    };
  }

  String get label {
    return switch (this) {
      SensitivityLevel.baixa => 'Baixa',
      SensitivityLevel.media => 'Média',
      SensitivityLevel.alta => 'Alta',
    };
  }

  int get alertThreshold {
    return switch (this) {
      SensitivityLevel.baixa => 90,
      SensitivityLevel.media => 80,
      SensitivityLevel.alta => 65,
    };
  }
}

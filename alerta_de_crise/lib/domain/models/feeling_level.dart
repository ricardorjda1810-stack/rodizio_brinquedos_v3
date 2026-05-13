enum FeelingLevel { bem, leve, moderado, intenso }

extension FeelingLevelText on FeelingLevel {
  static FeelingLevel fromKey(String key) {
    return FeelingLevel.values.firstWhere(
      (level) => level.key == key,
      orElse: () => FeelingLevel.bem,
    );
  }

  String get key {
    return switch (this) {
      FeelingLevel.bem => 'bem',
      FeelingLevel.leve => 'leve',
      FeelingLevel.moderado => 'moderado',
      FeelingLevel.intenso => 'intenso',
    };
  }

  String get label {
    return switch (this) {
      FeelingLevel.bem => 'Bem',
      FeelingLevel.leve => 'Leve ativação',
      FeelingLevel.moderado => 'Moderado',
      FeelingLevel.intenso => 'Intenso',
    };
  }
}

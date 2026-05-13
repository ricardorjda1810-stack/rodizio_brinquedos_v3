enum RiskState { normal, atencao, alerta }

extension RiskStateText on RiskState {
  static RiskState fromKey(String key) {
    return RiskState.values.firstWhere(
      (state) => state.key == key,
      orElse: () => RiskState.normal,
    );
  }

  String get label {
    return switch (this) {
      RiskState.normal => 'Normal',
      RiskState.atencao => 'Atenção',
      RiskState.alerta => 'Alerta',
    };
  }

  String get key {
    return switch (this) {
      RiskState.normal => 'normal',
      RiskState.atencao => 'atencao',
      RiskState.alerta => 'alerta',
    };
  }
}

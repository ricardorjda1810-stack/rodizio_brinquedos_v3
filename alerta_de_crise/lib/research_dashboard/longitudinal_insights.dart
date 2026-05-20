class LongitudinalInsights {
  final bool improvingTrend;
  final bool worseningTrend;
  final bool recoveryTrend;
  final bool confidenceTrend;
  final bool circadianStability;
  final double autonomicLoad;

  const LongitudinalInsights({
    required this.improvingTrend,
    required this.worseningTrend,
    required this.recoveryTrend,
    required this.confidenceTrend,
    required this.circadianStability,
    required this.autonomicLoad,
  });

  String get summaryLabel {
    if (worseningTrend) {
      return 'Carga fisiológica elevada';
    }
    if (improvingTrend && recoveryTrend) {
      return 'Recuperação favorável';
    }
    return 'Estável para observação';
  }
}

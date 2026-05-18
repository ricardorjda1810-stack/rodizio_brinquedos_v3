import 'dart:convert';

import 'package:drift/drift.dart';

import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import '../session_timeline/physiological_event_marker.dart';
import '../session_timeline/session_timeline_models.dart';
import 'forecast_confidence_service.dart';
import 'forecast_probability_model.dart';
import 'physiological_forecast_window.dart';
import 'predictive_forecast_models.dart';

class EscalationForecastService {
  final SignalFlowDatabase _database;
  final DateTime Function() _now;
  final ForecastProbabilityModel _probabilityModel;
  final ForecastConfidenceService _confidenceService;

  EscalationForecastService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
    ForecastProbabilityModel probabilityModel =
        const ForecastProbabilityModel(),
    ForecastConfidenceService confidenceService =
        const ForecastConfidenceService(),
  }) : _database = database ?? SignalFlowDatabase.instance,
       _now = now ?? DateTime.now,
       _probabilityModel = probabilityModel,
       _confidenceService = confidenceService;

  Future<EscalationForecast> generateForecast({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
    List<SessionTimeline> timelines = const [],
    AdaptiveBaselineProfile? adaptiveBaseline,
    PhysiologicalForecastWindow forecastWindow =
        PhysiologicalForecastWindow.nearFuture,
    double baselineStability = 100,
    bool persist = false,
  }) async {
    final generatedAt = _now();
    final probability = calculateEscalationProbability(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      confidenceScores: confidenceScores,
    );
    final forecastConfidence = _confidenceService.calculateConfidence(
      confidenceScores: confidenceScores,
      timelines: timelines,
      adaptiveBaseline: adaptiveBaseline,
      baselineStability: baselineStability,
    );
    final autonomicLoad = _autonomicLoad(trends, recoveryProfiles);
    final recoveryProtection = _recoveryProtection(recoveryProfiles);
    final forecast = EscalationForecast(
      id: 'forecast-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      forecastWindow: forecastWindow,
      escalationProbability: probability,
      forecastConfidence: forecastConfidence,
      escalationRiskLevel: determineForecastRisk(probability),
      contributingFactors: _contributingFactors(
        trends: trends,
        recoveryProfiles: recoveryProfiles,
        confidenceScores: confidenceScores,
        probability: probability,
        forecastConfidence: forecastConfidence,
      ),
      recoveryProtection: recoveryProtection,
      autonomicLoad: autonomicLoad,
    );

    if (persist) {
      await persistForecast(forecast);
    }

    return forecast;
  }

  double calculateEscalationProbability({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
  }) {
    return _probabilityModel.calculate(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      confidenceScores: confidenceScores,
    );
  }

  ForecastRiskLevel determineForecastRisk(double probability) {
    if (probability >= 75) {
      return ForecastRiskLevel.high;
    }
    if (probability >= 55) {
      return ForecastRiskLevel.elevated;
    }
    if (probability >= 30) {
      return ForecastRiskLevel.moderate;
    }
    return ForecastRiskLevel.low;
  }

  List<PhysiologicalEventMarker> buildOptionalMarkers({
    required EscalationForecast forecast,
    required String timelineId,
  }) {
    final markers = <PhysiologicalEventMarker>[];
    if (forecast.escalationRiskLevel == ForecastRiskLevel.elevated ||
        forecast.escalationRiskLevel == ForecastRiskLevel.high) {
      markers.add(
        _marker(
          forecast: forecast,
          timelineId: timelineId,
          type: EventType.forecastElevatedRisk,
          title: 'Previsão experimental: tendência elevada',
          description:
              'Probabilidade aumentada de escalada fisiológica; não é diagnóstico.',
          severity: forecast.escalationRiskLevel == ForecastRiskLevel.high
              ? Severity.high
              : Severity.medium,
        ),
      );
    }
    if (forecast.autonomicLoad >= 65) {
      markers.add(
        _marker(
          forecast: forecast,
          timelineId: timelineId,
          type: EventType.prolongedAutonomicLoad,
          title: 'Carga autonômica prolongada',
          description:
              'Sinais de ativação sustentados aparecem na previsão experimental.',
          severity: Severity.medium,
        ),
      );
    }
    if (forecast.recoveryProtection >= 45) {
      markers.add(
        _marker(
          forecast: forecast,
          timelineId: timelineId,
          type: EventType.recoveryProtectiveEffect,
          title: 'Efeito protetivo de recuperação',
          description:
              'Recuperação recente reduz a probabilidade estimada de escalada.',
          severity: Severity.low,
        ),
      );
    }
    return List.unmodifiable(markers);
  }

  Future<void> persistForecast(EscalationForecast forecast) async {
    await _database
        .into(_database.escalationForecastsTable)
        .insert(
          EscalationForecastsTableCompanion.insert(
            id: forecast.id,
            generatedAt: forecast.generatedAt,
            forecastWindowSeconds: forecast.forecastWindow.duration.inSeconds,
            forecastWindowLabel: forecast.forecastWindow.label,
            escalationProbability: forecast.escalationProbability,
            forecastConfidence: forecast.forecastConfidence.score,
            forecastConfidenceLevel: forecast.forecastConfidence.level.name,
            escalationRiskLevel: forecast.escalationRiskLevel.name,
            contributingFactorsJson: jsonEncode(forecast.contributingFactors),
            recoveryProtection: forecast.recoveryProtection,
            autonomicLoad: forecast.autonomicLoad,
            safetyCopy: forecast.safetyCopy,
          ),
        );
  }

  Future<List<EscalationForecast>> loadForecasts({int limit = 20}) async {
    final query = _database.select(_database.escalationForecastsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  List<String> _contributingFactors({
    required List<PhysiologicalTrend> trends,
    required List<AutonomicRecoveryProfile> recoveryProfiles,
    required List<SensorConfidenceScore> confidenceScores,
    required double probability,
    required ForecastConfidenceResult forecastConfidence,
  }) {
    final factors = <String>[];
    final trendAverage = _average(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final activationDensity = _average(
      trends.map((trend) => trend.activationDensity).toList(),
    );
    final heartRateSlope = _average(
      trends.map((trend) => trend.heartRateSlope).toList(),
    );
    final hrvSuppression = _average(
      trends.map((trend) => -trend.hrvSlope).toList(),
    );
    final fatigue = _average(
      recoveryProfiles
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final recovery = _average(
      recoveryProfiles.map((profile) => profile.recoveryRate * 100).toList(),
    );
    final confidence = _average(
      confidenceScores.map((score) => score.overallScore.toDouble()).toList(),
    );

    if (trendAverage >= 45) {
      factors.add('tendência recente de escalada fisiológica');
    }
    if (heartRateSlope > 0.35) {
      factors.add('sinais de ativação por inclinação de frequência cardíaca');
    }
    if (hrvSuppression > 0.2) {
      factors.add('supressão de HRV contribui para a probabilidade');
    }
    if (activationDensity >= 0.35) {
      factors.add('densidade de ativação fisiológica aumentada');
    }
    if (fatigue >= 45) {
      factors.add('fadiga autonômica aumenta a previsão experimental');
    }
    if (recovery >= 65) {
      factors.add('recuperação recente reduz a probabilidade estimada');
    }
    if (confidence < 60 ||
        forecastConfidence.level == ForecastConfidenceLevel.lowConfidence) {
      factors.add('confiança baixa exige leitura cautelosa da tendência');
    }
    if (factors.isEmpty) {
      factors.add(
        probability < 30
            ? 'sem sinais fortes de escalada fisiológica neste recorte'
            : 'combinação moderada de sinais de ativação',
      );
    }
    return List.unmodifiable(factors);
  }

  double _autonomicLoad(
    List<PhysiologicalTrend> trends,
    List<AutonomicRecoveryProfile> recoveryProfiles,
  ) {
    final escalation = _average(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final activation = _average(
      trends.map((trend) => trend.activationDensity * 100).toList(),
    );
    final fatigue = _average(
      recoveryProfiles
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final carryover = _average(
      recoveryProfiles.map((profile) => profile.stressCarryover * 100).toList(),
    );
    return ((escalation * 0.32) +
            (activation * 0.24) +
            (fatigue * 0.26) +
            (carryover * 0.18))
        .clamp(0, 100)
        .toDouble();
  }

  double _recoveryProtection(List<AutonomicRecoveryProfile> profiles) {
    final recovery = _average(
      profiles.map((profile) => profile.recoveryRate * 100).toList(),
    );
    final resilience = _average(
      profiles.map((profile) => profile.resilienceScore.toDouble()).toList(),
    );
    final fatigue = _average(
      profiles.map((profile) => profile.fatigueScore.toDouble()).toList(),
    );
    return ((recovery * 0.45) + (resilience * 0.35) + ((100 - fatigue) * 0.2))
        .clamp(0, 100)
        .toDouble();
  }

  PhysiologicalEventMarker _marker({
    required EscalationForecast forecast,
    required String timelineId,
    required EventType type,
    required String title,
    required String description,
    required Severity severity,
  }) {
    return PhysiologicalEventMarker(
      id: '$timelineId-${type.name}-${forecast.generatedAt.microsecondsSinceEpoch}',
      timestamp: forecast.generatedAt,
      type: type,
      title: title,
      description: description,
      severity: severity,
      source: 'predictive_forecasting',
    );
  }

  EscalationForecast _fromRow(EscalationForecastsTableData row) {
    final factors = jsonDecode(row.contributingFactorsJson);
    return EscalationForecast(
      id: row.id,
      generatedAt: row.generatedAt,
      forecastWindow: PhysiologicalForecastWindow(
        duration: Duration(seconds: row.forecastWindowSeconds),
        label: row.forecastWindowLabel,
      ),
      escalationProbability: row.escalationProbability,
      forecastConfidence: ForecastConfidenceResult(
        score: row.forecastConfidence,
        level: ForecastConfidenceLevel.values.byName(
          row.forecastConfidenceLevel,
        ),
        factors: const [],
      ),
      escalationRiskLevel: ForecastRiskLevel.values.byName(
        row.escalationRiskLevel,
      ),
      contributingFactors: factors is List
          ? factors.whereType<String>().toList(growable: false)
          : const [],
      recoveryProtection: row.recoveryProtection,
      autonomicLoad: row.autonomicLoad,
    );
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}

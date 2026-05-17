import '../data/crisis_detection/intervention_history_repository.dart';
import '../ui/crisis_detection/adaptive_baseline_debug_page.dart';
import '../ui/crisis_detection/apple_health_debug_page.dart';
import '../ui/crisis_detection/baseline_calibration_debug_page.dart';
import '../ui/crisis_detection/crisis_risk_debug_page.dart';
import '../ui/crisis_detection/csv_replay_debug_page.dart';
import '../ui/crisis_detection/database_audit_debug_page.dart';
import '../ui/crisis_detection/intervention_history_debug_page.dart';
import '../ui/crisis_detection/intervention_protocol_debug_page.dart';
import '../ui/crisis_detection/polar_h10_debug_page.dart';
import '../ui/crisis_detection/research_consent_debug_page.dart';
import '../ui/crisis_detection/research_export_debug_page.dart';
import '../ui/crisis_detection/sensor_provider_debug_page.dart';
import '../ui/crisis_detection/sensor_quality_debug_page.dart';
import '../ui/crisis_detection/session_timeline_debug_page.dart';
import '../ui/crisis_detection/watch_live_session_debug_page.dart';
import 'debug_hub_models.dart';

class SignalFlowDebugHubSections {
  static List<DebugHubSection> build() {
    return [
      DebugHubSection(
        title: 'Crisis Detection',
        items: [
          DebugHubItem(
            label: 'Crisis Risk Debug',
            description: 'Cenários simulados e motor estatístico auditável.',
            builder: (_) => const CrisisRiskDebugPage(),
          ),
          DebugHubItem(
            label: 'Baseline Calibration',
            description: 'Calibragem inicial simulada do padrão fisiológico.',
            builder: (_) => const BaselineCalibrationDebugPage(),
          ),
          DebugHubItem(
            label: 'Adaptive Baseline',
            description: 'Perfis circadianos e baseline dinâmico.',
            builder: (_) => const AdaptiveBaselineDebugPage(),
          ),
          DebugHubItem(
            label: 'Session Timeline',
            description: 'Marcadores temporais e análise before/during/after.',
            builder: (_) => const SessionTimelineDebugPage(),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Sensors',
        items: [
          DebugHubItem(
            label: 'Sensor Provider',
            description: 'Abstração de provider e ingestão manual.',
            builder: (_) => const SensorProviderDebugPage(),
          ),
          DebugHubItem(
            label: 'Apple Health',
            description: 'Bridge inicial HealthKit para leituras simples.',
            builder: (_) => const AppleHealthDebugPage(),
          ),
          DebugHubItem(
            label: 'Polar H10',
            description: 'BLE RR intervals para pesquisa fisiológica.',
            builder: (_) => const PolarH10DebugPage(),
          ),
          DebugHubItem(
            label: 'Sensor Quality',
            description: 'Confiança do sinal e artefatos RR.',
            builder: (_) => const SensorQualityDebugPage(),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Watch Sessions',
        items: [
          DebugHubItem(
            label: 'Watch Live Session',
            description: 'Arquitetura de sessão temporária Apple Watch.',
            builder: (_) => const WatchLiveSessionDebugPage(),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Replay & Research',
        items: [
          DebugHubItem(
            label: 'CSV Replay',
            description: 'Replay local de datasets fisiológicos em CSV.',
            builder: (_) => const CsvReplayDebugPage(),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Intervention',
        items: [
          DebugHubItem(
            label: 'Intervention Protocol',
            description: 'Pausa guiada para ativação acima do padrão.',
            builder: (_) => const InterventionProtocolDebugPage(),
          ),
          DebugHubItem(
            label: 'Intervention History',
            description: 'Registro longitudinal local de protocolos debug.',
            builder: (_) => InterventionHistoryDebugPage(
              repository: InterventionHistoryRepository(
                persistSyncWrites: true,
              ),
            ),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Consent & Safety',
        items: [
          DebugHubItem(
            label: 'Research Consent',
            description: 'Consentimento local e textos de segurança.',
            builder: (_) => const ResearchConsentDebugPage(),
          ),
        ],
      ),
      DebugHubSection(
        title: 'Export Tools',
        items: [
          DebugHubItem(
            label: 'Research Export',
            description: 'Export local/debug de eventos e estatísticas.',
            builder: (_) => const ResearchExportDebugPage(),
          ),
          DebugHubItem(
            label: 'Database Audit',
            description: 'Auditoria técnica de schema e integridade Drift.',
            builder: (_) => const DatabaseAuditDebugPage(),
          ),
        ],
      ),
    ];
  }

  const SignalFlowDebugHubSections._();
}

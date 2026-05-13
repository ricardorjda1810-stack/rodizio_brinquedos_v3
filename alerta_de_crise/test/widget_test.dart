import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alerta_de_crise/app_state.dart';
import 'package:alerta_de_crise/data/export/csv_exporter.dart';
import 'package:alerta_de_crise/data/repositories/local_calibration_repository.dart';
import 'package:alerta_de_crise/data/repositories/local_event_repository.dart';
import 'package:alerta_de_crise/data/repositories/local_research_session_repository.dart';
import 'package:alerta_de_crise/data/repositories/mock_risk_repository.dart';
import 'package:alerta_de_crise/data/repositories/onboarding_repository.dart';
import 'package:alerta_de_crise/data/sensors/healthkit_sensor_provider.dart';
import 'package:alerta_de_crise/data/sensors/mock_sensor_provider.dart';
import 'package:alerta_de_crise/data/sensors/sensor_provider.dart';
import 'package:alerta_de_crise/domain/models/calibration_feedback.dart';
import 'package:alerta_de_crise/domain/models/feeling_level.dart';
import 'package:alerta_de_crise/domain/models/research_session.dart';
import 'package:alerta_de_crise/domain/models/risk_event.dart';
import 'package:alerta_de_crise/domain/models/risk_state.dart';
import 'package:alerta_de_crise/domain/models/session_sample.dart';
import 'package:alerta_de_crise/domain/models/sensor_sample.dart';
import 'package:alerta_de_crise/domain/models/sensitivity_level.dart';
import 'package:alerta_de_crise/domain/risk_engine.dart';
import 'package:alerta_de_crise/main.dart';
import 'package:alerta_de_crise/ui/widgets/simple_timeline_chart.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows onboarding on first opening', (tester) async {
    await tester.pumpWidget(const AlertaDeCriseApp());
    await tester.pumpAndSettle();

    expect(find.text('Alerta de Crise'), findsOneWidget);
    expect(
      find.text(
        'O app observa sinais de ativação fisiológica e ajuda você a fazer uma regulação curta.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Este app não realiza diagnóstico, não substitui atendimento profissional e não deve ser usado em emergências.',
      ),
      findsOneWidget,
    );
    expect(find.text('Entendi e começar'), findsOneWidget);
    expect(find.text('Estado atual'), findsNothing);
  });

  testWidgets('accepting onboarding saves flag and opens home', (tester) async {
    await tester.pumpWidget(const AlertaDeCriseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entendi e começar'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(OnboardingRepository.onboardingSeenKey), isTrue);
    expect(find.text('Estado atual'), findsOneWidget);
  });

  testWidgets('home shows current attention state', (tester) async {
    await _pumpAppWithOnboardingSeen(tester);

    expect(find.text('Estado atual'), findsOneWidget);
    expect(find.text('Atenção'), findsOneWidget);
    expect(find.text('92 bpm'), findsOneWidget);
    expect(find.text('28 ms'), findsOneWidget);
    expect(find.text('68/100'), findsOneWidget);
    expect(
      find.text('Seu padrão recente: FC 72 bpm • HRV 42 ms'),
      findsOneWidget,
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar simulação'), findsOneWidget);
  });

  testWidgets('simple timeline chart renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SimpleTimelineChart(
            values: [1, 2, 3],
            color: Colors.indigo,
            label: 'Teste',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Teste'), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('simple timeline painter handles empty single and equal values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SimpleTimelineChart(
                values: [],
                color: Colors.indigo,
                label: 'Vazio',
              ),
              SimpleTimelineChart(
                values: [10],
                color: Colors.teal,
                label: 'Um ponto',
              ),
              SimpleTimelineChart(
                values: [7, 7, 7],
                color: Colors.green,
                label: 'Iguais',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Vazio'), findsOneWidget);
    expect(find.text('Um ponto'), findsOneWidget);
    expect(find.text('Iguais'), findsOneWidget);
  });

  testWidgets('simple timeline chart paints integer and double values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SimpleTimelineChart(
                values: [72, 78, 90],
                color: Colors.red,
                label: 'Inteiros',
              ),
              SimpleTimelineChart(
                values: [28.5, 30, 31.5],
                color: Colors.blue,
                label: 'Decimais',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Inteiros'), findsOneWidget);
    expect(find.text('Decimais'), findsOneWidget);
  });

  testWidgets('history route lists mocked events', (tester) async {
    await _pumpAppWithOnboardingSeen(tester);

    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Alerta automático'), findsOneWidget);
    expect(find.text('Intervenção manual'), findsOneWidget);
    expect(find.text('Alerta automático anterior'), findsOneWidget);
  });

  test('manual intervention is completed and added to the top', () {
    final appState = AppState.fromRepository(const MockRiskRepository());
    final initialCount = appState.events.length;

    appState.startManualIntervention();

    expect(appState.activeEvent?.title, 'Intervenção manual');
    expect(appState.activeEvent?.beforeHeartRate, 92);
    expect(appState.activeEvent?.beforeHrv, 28);

    appState.completeActiveEvent('Sim, melhorei');

    expect(appState.activeEvent, isNull);
    expect(appState.events.length, initialCount + 1);
    expect(appState.events.first.title, 'Intervenção manual');
    expect(appState.events.first.feedback, 'Sim, melhorei');
    expect(appState.events.first.endedAt, isNotNull);
    expect(appState.events.first.afterHeartRate, lessThan(92));
    expect(appState.events.first.afterHrv, greaterThan(28));
  });

  test('risk engine evaluates simulated activation levels', () {
    const engine = RiskEngine();
    final normal = engine.evaluate(
      SensorSample(
        id: 'normal',
        timestamp: DateTime(2026),
        heartRate: 72,
        hrv: 42,
        motionState: 'parado',
      ),
      baselineHeartRate: 72,
      baselineHrv: 42,
      sensitivity: SensitivityLevel.media,
    );
    final alert = engine.evaluate(
      SensorSample(
        id: 'alert',
        timestamp: DateTime(2026),
        heartRate: 112,
        hrv: 18,
        motionState: 'parado',
      ),
      baselineHeartRate: 72,
      baselineHrv: 42,
      sensitivity: SensitivityLevel.media,
    );

    expect(normal.state, RiskState.normal);
    expect(normal.score, 0);
    expect(alert.state, RiskState.alerta);
    expect(alert.score, 100);
  });

  test('simulation updates sample and can be stopped', () {
    final appState = AppState.fromRepository(const MockRiskRepository());

    appState.startSimulation();

    expect(appState.isSimulationRunning, isTrue);
    expect(appState.currentRiskState, RiskState.normal);
    expect(appState.currentScore, 0);
    expect(appState.currentSample.heartRate, 72);

    appState.stopSimulation();

    expect(appState.isSimulationRunning, isFalse);
    appState.dispose();
  });

  test('app state uses injected mock sensor provider', () {
    final appState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      sensorProvider: MockSensorProvider(),
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    appState.startSimulation();

    expect(appState.sensorProviderType, SensorProviderType.mock);
    expect(appState.currentSample.id, startsWith('sim-normal-'));
    expect(appState.currentSample.heartRate, 72);
    expect(appState.currentRiskState, RiskState.normal);
    appState.dispose();
  });

  test('healthkit provider is prepared without real samples', () async {
    const provider = HealthKitSensorProvider();

    expect(provider.type, SensorProviderType.healthkit);
    expect(await provider.getLatestSample(), isNull);
    expect(await provider.watchSamples().isEmpty, isTrue);
  });

  test('switching sensor provider to healthkit does not break app state', () {
    final appState = AppState.fromRepository(const MockRiskRepository());

    appState.updateSensorProvider(SensorProviderType.healthkit);
    appState.startSimulation();

    expect(appState.sensorProviderType, SensorProviderType.healthkit);
    expect(appState.isHealthKitInPreparation, isTrue);
    expect(appState.currentSample.heartRate, 92);
    expect(appState.currentStatusMessage, contains('Integração em preparação'));
    appState.dispose();
  });

  testWidgets('settings page controls simulation', (tester) async {
    await _pumpAppWithOnboardingSeen(tester);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Status: inativa'), findsOneWidget);
    expect(find.text('Fonte de dados'), findsOneWidget);
    expect(find.text('Simulação'), findsWidgets);
    expect(find.text('HealthKit (experimental)'), findsOneWidget);

    await tester.tap(find.text('Iniciar simulação'));
    await tester.pumpAndSettle();

    expect(find.text('Status: ativa'), findsOneWidget);
    expect(find.text('Parar simulação'), findsOneWidget);
  });

  testWidgets('research page starts session and collects samples', (
    tester,
  ) async {
    await _pumpAppWithOnboardingSeen(tester);

    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modo pesquisa'));
    await tester.pumpAndSettle();

    expect(find.text('Pesquisa'), findsOneWidget);
    expect(find.text('Sem sessão ativa'), findsOneWidget);

    await tester.tap(find.text('Iniciar sessão'));
    await tester.pumpAndSettle();

    expect(find.text('Sessão ativa'), findsOneWidget);
    expect(find.text('Amostras coletadas: 0'), findsOneWidget);

    await tester.tap(find.text('Iniciar simulação'));
    await tester.pumpAndSettle();

    expect(find.text('Amostras coletadas: 1'), findsOneWidget);
    expect(find.text('Última amostra'), findsOneWidget);
  });

  testWidgets('calibration route registers feedback', (tester) async {
    await _pumpAppWithOnboardingSeen(tester);

    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar como estou'));
    await tester.pumpAndSettle();

    expect(find.text('Calibragem'), findsOneWidget);
    expect(find.text('Como você está se sentindo agora?'), findsOneWidget);

    await tester.tap(find.text('Leve ativação'));
    await tester.pumpAndSettle();

    expect(find.text('Última percepção subjetiva registrada'), findsOneWidget);
    expect(find.text('Leve ativação'), findsWidgets);
  });

  test('research session stores simulation samples', () {
    final appState = AppState.fromRepository(const MockRiskRepository());

    appState.startResearchSession();
    appState.startSimulation();

    final session = appState.currentResearchSession;

    expect(appState.hasActiveResearchSession, isTrue);
    expect(session, isNotNull);
    expect(session!.samples, hasLength(1));
    expect(session.samples.first.heartRate, appState.currentSample.heartRate);
    expect(session.samples.first.riskScore, appState.currentScore);

    appState.endResearchSession();

    expect(appState.hasActiveResearchSession, isFalse);
    expect(appState.currentResearchSession?.endedAt, isNotNull);
    expect(appState.researchSessions, hasLength(1));
    appState.dispose();
  });

  test('calibration feedback stores current sample and state', () {
    final appState = AppState.fromRepository(const MockRiskRepository());

    appState.addCalibrationFeedback(FeelingLevel.moderado);

    expect(appState.calibrationFeedbacks, hasLength(1));
    expect(
      appState.lastCalibrationFeedback?.feelingLevel,
      FeelingLevel.moderado,
    );
    expect(appState.lastCalibrationFeedback?.label, 'Moderado');
    expect(appState.lastCalibrationFeedback?.heartRate, 92);
    expect(appState.lastCalibrationFeedback?.hrv, 28);
    expect(appState.lastCalibrationFeedback?.riskScore, 68);
    expect(appState.lastCalibrationFeedback?.riskState, RiskState.atencao);
    appState.dispose();
  });

  test('alert sample creates pending alert that can be dismissed', () {
    final appState = AppState(
      currentSample: SensorSample(
        id: 'alert',
        timestamp: DateTime(2026),
        heartRate: 112,
        hrv: 18,
        motionState: 'parado',
      ),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
    );

    expect(appState.currentRiskState, RiskState.alerta);
    expect(appState.hasPendingAlert, isTrue);

    appState.dismissPendingAlert();

    expect(appState.hasPendingAlert, isFalse);
    expect(appState.events.first.title, 'Alerta observado');
    expect(appState.events.first.feedback, 'Estou bem');
    appState.dispose();
  });

  test('regular now clears pending alert and creates active alert event', () {
    final appState = AppState(
      currentSample: SensorSample(
        id: 'alert',
        timestamp: DateTime(2026),
        heartRate: 112,
        hrv: 18,
        motionState: 'parado',
      ),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
    );

    appState.startAlertIntervention();

    expect(appState.hasPendingAlert, isFalse);
    expect(appState.activeEvent?.title, 'Alerta automático');
    expect(appState.activeEvent?.state, RiskState.alerta);
    appState.dispose();
  });

  test('baseline uses fallback with fewer than five recent samples', () {
    final appState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      recentSamples: [
        _sample('one', 80, 40),
        _sample('two', 82, 38),
        _sample('three', 84, 36),
        _sample('four', 86, 34),
      ],
    );

    expect(appState.baselineHeartRate, 72);
    expect(appState.baselineHrv, 42);
    appState.dispose();
  });

  test('baseline uses recent sample averages from five samples onward', () {
    final appState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      recentSamples: [
        _sample('one', 70, 40),
        _sample('two', 72, 42),
        _sample('three', 74, 44),
        _sample('four', 76, 46),
        _sample('five', 78, 48),
      ],
    );

    expect(appState.baselineHeartRate, 74);
    expect(appState.baselineHrv, 44);
    appState.dispose();
  });

  test('sensitivity changes risk state without changing score', () async {
    final appState = AppState(
      currentSample: _sample('current', 112, 18),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    await appState.updateSensitivity(SensitivityLevel.baixa);

    expect(appState.currentScore, 100);
    expect(appState.currentRiskState, RiskState.alerta);

    await appState.updateSensitivity(SensitivityLevel.alta);

    expect(appState.currentScore, 100);
    expect(appState.currentRiskState, RiskState.alerta);
    appState.dispose();
  });

  test('high sensitivity alerts earlier than medium sensitivity', () async {
    final appState = AppState(
      currentSample: _sample('current', 100, 32),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    await appState.updateSensitivity(SensitivityLevel.media);
    expect(appState.currentScore, 76);
    expect(appState.currentRiskState, RiskState.atencao);

    await appState.updateSensitivity(SensitivityLevel.alta);
    expect(appState.currentRiskState, RiskState.alerta);
    appState.dispose();
  });

  test('sensitivity is persisted in shared preferences', () async {
    final appState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    await appState.updateSensitivity(SensitivityLevel.alta);
    appState.dispose();

    final reloadedState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      loadPersistedEvents: false,
    );
    await reloadedState.loadSettings();

    expect(reloadedState.sensitivity, SensitivityLevel.alta);
    reloadedState.dispose();
  });

  test(
    'clear history removes events and reset onboarding clears flag',
    () async {
      final appState = AppState.fromRepository(const MockRiskRepository());
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(OnboardingRepository.onboardingSeenKey, true);

      expect(appState.events, isNotEmpty);

      appState.addCalibrationFeedback(FeelingLevel.bem);
      appState.startResearchSession();
      appState.startSimulation();
      appState.endResearchSession();

      expect(appState.calibrationFeedbacks, isNotEmpty);
      expect(appState.researchSessions, isNotEmpty);

      await appState.clearHistory();
      await appState.resetOnboarding();

      expect(appState.events, isEmpty);
      expect(appState.calibrationFeedbacks, isEmpty);
      expect(appState.researchSessions, isEmpty);
      expect(
        preferences.getBool(OnboardingRepository.onboardingSeenKey),
        isFalse,
      );
      appState.dispose();
    },
  );

  test('risk event serializes to and from json', () {
    final event = _event('json-event');

    final decoded = RiskEvent.fromJson(event.toJson());

    expect(decoded.id, event.id);
    expect(decoded.startedAt, event.startedAt);
    expect(decoded.endedAt, event.endedAt);
    expect(decoded.state, event.state);
    expect(decoded.feedback, event.feedback);
  });

  test('calibration feedback serializes to and from json', () {
    final feedback = _calibrationFeedback('feedback-json');

    final decoded = CalibrationFeedback.fromJson(feedback.toJson());

    expect(decoded.id, feedback.id);
    expect(decoded.timestamp, feedback.timestamp);
    expect(decoded.feelingLevel, feedback.feelingLevel);
    expect(decoded.label, feedback.label);
    expect(decoded.riskState, feedback.riskState);
  });

  test('research session serializes to and from json', () {
    final session = _researchSession('session-json');

    final decoded = ResearchSession.fromJson(session.toJson());

    expect(decoded.id, session.id);
    expect(decoded.startedAt, session.startedAt);
    expect(decoded.endedAt, session.endedAt);
    expect(decoded.samples, hasLength(1));
    expect(decoded.samples.first.riskState, RiskState.atencao);
  });

  test('local repository persists risk events', () async {
    const repository = LocalEventRepository();
    final event = _event('persisted-event');

    await repository.saveEvents([event]);
    final loadedEvents = await repository.loadEvents();

    expect(loadedEvents, hasLength(1));
    expect(loadedEvents.first.id, event.id);
    expect(loadedEvents.first.feedback, 'Sim, melhorei');
  });

  test('local calibration repository persists feedbacks', () async {
    const repository = LocalCalibrationRepository();
    final feedback = _calibrationFeedback('persisted-feedback');

    await repository.saveFeedbacks([feedback]);
    final loadedFeedbacks = await repository.loadFeedbacks();

    expect(loadedFeedbacks, hasLength(1));
    expect(loadedFeedbacks.first.id, feedback.id);
    expect(loadedFeedbacks.first.feelingLevel, FeelingLevel.leve);
  });

  test('local research repository persists ended sessions', () async {
    const repository = LocalResearchSessionRepository();
    final session = _researchSession('persisted-session');

    await repository.saveSessions([session]);
    final loadedSessions = await repository.loadSessions();

    expect(loadedSessions, hasLength(1));
    expect(loadedSessions.first.id, session.id);
    expect(loadedSessions.first.samples, hasLength(1));
  });

  test('app state loads persisted feedbacks and research sessions', () async {
    const calibrationRepository = LocalCalibrationRepository();
    const researchRepository = LocalResearchSessionRepository();
    final feedback = _calibrationFeedback('state-feedback');
    final session = _researchSession('state-session');

    await calibrationRepository.saveFeedbacks([feedback]);
    await researchRepository.saveSessions([session]);

    final appState = AppState(
      currentSample: _sample('current', 90, 30),
      currentRiskState: RiskState.normal,
      currentStatusMessage: '',
      events: const [],
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );
    await appState.loadCalibrationFeedbacks();
    await appState.loadResearchSessions();

    expect(appState.calibrationFeedbacks.first.id, feedback.id);
    expect(appState.researchSessions.first.id, session.id);
    appState.dispose();
  });

  test('csv exporter writes expected header', () {
    const exporter = CsvExporter();

    final csv = exporter.exportEvents(const []);

    expect(
      csv,
      'id,startedAt,endedAt,state,maxScore,beforeHeartRate,beforeHrv,afterHeartRate,afterHrv,title,description,feedback',
    );
  });

  test('csv exporter writes one event line', () {
    const exporter = CsvExporter();

    final csv = exporter.exportEvents([_event('csv-event')]);
    final lines = csv.split('\n');

    expect(lines, hasLength(2));
    expect(
      lines.last,
      'csv-event,2026-05-13T12:00:00.000,2026-05-13T12:02:00.000,alerta,82,108,21,88,34,Alerta automático,Sinais de ativação aumentaram enquanto o corpo estava parado.,"Sim, melhorei"',
    );
  });

  test('csv exporter escapes quotes commas and line breaks', () {
    const exporter = CsvExporter();
    final event = RiskEvent(
      id: 'escape-event',
      startedAt: DateTime(2026, 5, 13, 12),
      state: RiskState.atencao,
      maxScore: 60,
      beforeHeartRate: 92,
      beforeHrv: 28,
      title: 'Intervenção, manual',
      description: 'Respirar "devagar"\najudou',
      feedback: 'Mais, ou "menos"',
    );

    final csv = exporter.exportEvents([event]);

    expect(
      csv,
      contains(
        'escape-event,2026-05-13T12:00:00.000,,atencao,60,92,28,,,"Intervenção, manual","Respirar ""devagar""\najudou","Mais, ou ""menos"""',
      ),
    );
  });

  test('csv exporter writes research session samples', () {
    const exporter = CsvExporter();
    final csv = exporter.exportSessionSamples([
      SessionSample(
        timestamp: DateTime(2026, 5, 13, 12),
        heartRate: 92,
        hrv: 28,
        riskScore: 68,
        riskState: RiskState.atencao,
        motionState: 'parado',
      ),
    ]);

    expect(
      csv,
      'timestamp,heartRate,hrv,riskScore,riskState,motionState\n2026-05-13T12:00:00.000,92,28,68,atencao,parado',
    );
  });

  test('csv exporter writes calibration feedbacks', () {
    const exporter = CsvExporter();
    final csv = exporter.exportCalibrationFeedbacks([
      CalibrationFeedback(
        id: 'feedback-1',
        timestamp: DateTime(2026, 5, 13, 12),
        feelingLevel: FeelingLevel.leve,
        label: 'Leve ativação',
        heartRate: 92,
        hrv: 28,
        riskScore: 68,
        riskState: RiskState.atencao,
      ),
    ]);

    expect(
      csv,
      'id,timestamp,feelingLevel,label,heartRate,hrv,riskScore,riskState\nfeedback-1,2026-05-13T12:00:00.000,leve,Leve ativação,92,28,68,atencao',
    );
  });
}

Future<void> _pumpAppWithOnboardingSeen(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    OnboardingRepository.onboardingSeenKey: true,
  });
  await tester.pumpWidget(const AlertaDeCriseApp());
  await tester.pumpAndSettle();
}

SensorSample _sample(String id, int heartRate, int hrv) {
  return SensorSample(
    id: id,
    timestamp: DateTime(2026),
    heartRate: heartRate,
    hrv: hrv,
    motionState: 'parado',
  );
}

RiskEvent _event(String id) {
  return RiskEvent(
    id: id,
    startedAt: DateTime(2026, 5, 13, 12),
    endedAt: DateTime(2026, 5, 13, 12, 2),
    state: RiskState.alerta,
    maxScore: 82,
    beforeHeartRate: 108,
    beforeHrv: 21,
    afterHeartRate: 88,
    afterHrv: 34,
    title: 'Alerta automático',
    description:
        'Sinais de ativação aumentaram enquanto o corpo estava parado.',
    feedback: 'Sim, melhorei',
  );
}

CalibrationFeedback _calibrationFeedback(String id) {
  return CalibrationFeedback(
    id: id,
    timestamp: DateTime(2026, 5, 13, 12),
    feelingLevel: FeelingLevel.leve,
    label: 'Leve ativação',
    heartRate: 92,
    hrv: 28,
    riskScore: 68,
    riskState: RiskState.atencao,
  );
}

ResearchSession _researchSession(String id) {
  return ResearchSession(
    id: id,
    startedAt: DateTime(2026, 5, 13, 12),
    endedAt: DateTime(2026, 5, 13, 12, 5),
    notes: 'Sessão simulada',
    samples: [
      SessionSample(
        timestamp: DateTime(2026, 5, 13, 12, 1),
        heartRate: 92,
        hrv: 28,
        riskScore: 68,
        riskState: RiskState.atencao,
        motionState: 'parado',
      ),
    ],
  );
}

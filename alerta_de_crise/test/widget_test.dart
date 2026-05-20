import 'dart:async';

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
import 'package:alerta_de_crise/domain/models/collection_diagnostics.dart';
import 'package:alerta_de_crise/domain/models/feeling_level.dart';
import 'package:alerta_de_crise/domain/models/research_session.dart';
import 'package:alerta_de_crise/domain/models/risk_event.dart';
import 'package:alerta_de_crise/domain/models/risk_state.dart';
import 'package:alerta_de_crise/domain/models/session_sample.dart';
import 'package:alerta_de_crise/domain/models/sensor_sample.dart';
import 'package:alerta_de_crise/domain/models/sensitivity_level.dart';
import 'package:alerta_de_crise/domain/models/temporal_sample_analysis.dart';
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

    expect(find.text('SignalFlow'), findsOneWidget);
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

  test('mock sensor provider permissions are always granted', () async {
    final provider = MockSensorProvider();

    expect(await provider.hasPermissions(), isTrue);
    expect(await provider.requestPermissions(), isTrue);
    expect(provider.permissionStatusMessage, 'Simulação ativa.');
  });

  test('healthkit provider in test environment does not break', () async {
    final provider = HealthKitSensorProvider();

    expect(provider.type, SensorProviderType.healthkit);
    expect(await provider.getLatestSample(), isNull);
    final subscription = provider.watchSamples().listen((_) {});
    await subscription.cancel();
    expect(await provider.hasPermissions(), isFalse);
    expect(await provider.requestPermissions(), isFalse);
    expect(provider.permissionStatusMessage, contains('HealthKit'));
  });

  test('healthkit debug status does not break in test environment', () async {
    final provider = HealthKitSensorProvider();

    final status = await provider.debugHealthKitStatus();

    expect(status, contains('Diagnóstico bruto HealthKit'));
    expect(status, contains('Permissões:'));
  });

  test(
    'switching sensor provider to healthkit does not break app state',
    () async {
      final appState = AppState(
        currentSample: _sample('current', 92, 28),
        currentRiskState: RiskState.atencao,
        currentStatusMessage: '',
        events: const [],
        loadPersistedEvents: false,
        loadPersistedSettings: false,
      );

      appState.updateSensorProvider(SensorProviderType.healthkit);
      appState.startSimulation();
      final granted = await appState.requestCurrentProviderPermissions();

      expect(appState.sensorProviderType, SensorProviderType.healthkit);
      expect(appState.isHealthKitInPreparation, isTrue);
      expect(granted, isFalse);
      expect(appState.dataSourcePermissionGranted, isFalse);
      expect(appState.dataSourcePermissionMessage, contains('HealthKit'));
      expect(appState.currentSample.heartRate, 92);
      expect(appState.currentStatusMessage, contains('HealthKit selecionado'));
      appState.dispose();
    },
  );

  test('app state handles null healthkit sample safely', () async {
    final appState = AppState(
      currentSample: _sample('current', 92, 28),
      currentRiskState: RiskState.atencao,
      currentStatusMessage: '',
      events: const [],
      sensorProvider: _NullHealthKitSensorProvider(),
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    final loaded = await appState.loadLatestHealthKitSample();

    expect(loaded, isFalse);
    expect(appState.sensorProviderType, SensorProviderType.healthkit);
    expect(appState.hasLoadedHealthKitSample, isFalse);
    expect(appState.currentSample.heartRate, 92);
    expect(appState.currentStatusMessage, 'Nenhum dado recente encontrado.');
    appState.dispose();
  });

  test('app state collects healthkit stream samples during session', () async {
    final provider = _StreamHealthKitSensorProvider();
    final appState = AppState(
      currentSample: _sample('current', 92, 28),
      currentRiskState: RiskState.atencao,
      currentStatusMessage: '',
      events: const [],
      sensorProvider: provider,
      loadPersistedEvents: false,
      loadPersistedSettings: false,
    );

    appState.startResearchSession();
    provider.add(_sample('healthkit-1', 88, 35, motionState: 'healthkit'));
    await Future<void>.delayed(Duration.zero);

    expect(appState.isHealthKitSessionCollectionActive, isTrue);
    expect(appState.currentSample.id, 'healthkit-1');
    expect(appState.currentResearchSession?.samples, hasLength(1));
    expect(appState.currentResearchSession?.samples.first.heartRate, 88);

    provider.add(_sample('healthkit-1-copy', 88, 35, motionState: 'healthkit'));
    await Future<void>.delayed(Duration.zero);

    expect(appState.currentResearchSession?.samples, hasLength(1));
    expect(appState.collectionDiagnostics.duplicateSamplesSkipped, 1);

    appState.endResearchSession();
    await Future<void>.delayed(Duration.zero);
    expect(appState.isHealthKitSessionCollectionActive, isFalse);
    expect(provider.isCanceled, isTrue);

    provider.add(_sample('healthkit-2', 90, 32, motionState: 'healthkit'));
    await Future<void>.delayed(Duration.zero);

    expect(appState.researchSessions.first.samples, hasLength(1));
    await provider.close();
    appState.dispose();
  });

  test(
    'healthkit session accepts heart rate sample without real hrv',
    () async {
      final provider = _StreamHealthKitSensorProvider();
      final appState = AppState(
        currentSample: _sample('current', 92, 28),
        currentRiskState: RiskState.atencao,
        currentStatusMessage: '',
        events: const [],
        sensorProvider: provider,
        loadPersistedEvents: false,
        loadPersistedSettings: false,
      );

      appState.startResearchSession();
      provider.add(
        _sample(
          'healthkit-fc-only',
          84,
          40,
          motionState: 'healthkit-hrv-indisponivel',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final sample = appState.currentResearchSession!.samples.single;
      expect(sample.heartRate, 84);
      expect(sample.hrv, 40);
      expect(sample.motionState, 'healthkit-hrv-indisponivel');
      await provider.close();
      appState.dispose();
    },
  );

  test('collection diagnostics starts empty', () {
    final diagnostics = CollectionDiagnostics.empty(sourceLabel: 'HealthKit');

    expect(diagnostics.totalSamples, 0);
    expect(diagnostics.heartRateSamples, 0);
    expect(diagnostics.hrvSamples, 0);
    expect(diagnostics.missingHeartRateCount, 0);
    expect(diagnostics.missingHrvCount, 0);
    expect(diagnostics.duplicateSamplesSkipped, 0);
    expect(diagnostics.firstSampleAt, isNull);
    expect(diagnostics.lastSampleAt, isNull);
    expect(diagnostics.averageIntervalSeconds, 0);
    expect(diagnostics.minIntervalSeconds, 0);
    expect(diagnostics.maxIntervalSeconds, 0);
    expect(diagnostics.sourceLabel, 'HealthKit');
  });

  test('collection diagnostics handles one sample', () {
    final sample = _sessionSample(DateTime(2026, 5, 13, 12), 92, 28);

    final diagnostics = CollectionDiagnostics.empty(
      sourceLabel: 'HealthKit',
    ).addSample(sample);

    expect(diagnostics.totalSamples, 1);
    expect(diagnostics.heartRateSamples, 1);
    expect(diagnostics.hrvSamples, 1);
    expect(diagnostics.firstSampleAt, sample.timestamp);
    expect(diagnostics.lastSampleAt, sample.timestamp);
    expect(diagnostics.averageIntervalSeconds, 0);
    expect(diagnostics.minIntervalSeconds, 0);
    expect(diagnostics.maxIntervalSeconds, 0);
  });

  test('collection diagnostics handles multiple samples', () {
    final first = _sessionSample(DateTime(2026, 5, 13, 12), 92, 28);
    final second = _sessionSample(DateTime(2026, 5, 13, 12, 0, 15), 94, 27);
    final third = _sessionSample(DateTime(2026, 5, 13, 12, 0, 45), 96, 26);

    final diagnostics = CollectionDiagnostics.empty(
      sourceLabel: 'HealthKit',
    ).addSample(first).addSample(second).addSample(third);

    expect(diagnostics.totalSamples, 3);
    expect(diagnostics.averageIntervalSeconds, 22.5);
    expect(diagnostics.minIntervalSeconds, 15);
    expect(diagnostics.maxIntervalSeconds, 30);
    expect(diagnostics.firstSampleAt, first.timestamp);
    expect(diagnostics.lastSampleAt, third.timestamp);
  });

  test('collection diagnostics counts missing hrv', () {
    final diagnostics = CollectionDiagnostics.empty(sourceLabel: 'HealthKit')
        .addSample(
          _sessionSample(
            DateTime(2026, 5, 13, 12),
            84,
            40,
            motionState: 'healthkit-hrv-indisponivel',
          ),
        );

    expect(diagnostics.hrvSamples, 0);
    expect(diagnostics.missingHrvCount, 1);
    expect(diagnostics.heartRateSamples, 1);
  });

  test('temporal analysis handles zero samples', () {
    final analysis = TemporalSampleAnalysis.fromSamples(const []);

    expect(analysis.totalSamples, 0);
    expect(analysis.qualityLabel, 'Sem dados');
    expect(analysis.intervalsSeconds, isEmpty);
  });

  test('temporal analysis handles one sample', () {
    final sample = _sessionSample(DateTime(2026, 5, 13, 12), 92, 28);

    final analysis = TemporalSampleAnalysis.fromSamples([sample]);

    expect(analysis.totalSamples, 1);
    expect(analysis.firstSampleAt, sample.timestamp);
    expect(analysis.lastSampleAt, sample.timestamp);
    expect(analysis.averageIntervalSeconds, 0);
    expect(analysis.qualityLabel, 'Bom');
  });

  test('temporal analysis calculates average median and gaps', () {
    final analysis = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 0, 10), 93, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 0, 40), 94, 27),
      _sessionSample(DateTime(2026, 5, 13, 12, 2, 40), 95, 27),
    ]);

    expect(analysis.totalSamples, 4);
    expect(analysis.durationSeconds, 160);
    expect(analysis.intervalsSeconds, [10, 30, 120]);
    expect(analysis.averageIntervalSeconds, 160 / 3);
    expect(analysis.medianIntervalSeconds, 30);
    expect(analysis.minIntervalSeconds, 10);
    expect(analysis.maxIntervalSeconds, 120);
    expect(analysis.longGapCount, 1);
    expect(analysis.longestGapSeconds, 120);
    expect(analysis.samplesPerMinute, 1.5);
  });

  test('temporal analysis quality labels sparse moderate and good', () {
    final good = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 0, 30), 93, 28),
    ]);
    final moderate = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 1), 93, 28),
    ]);
    final sparse = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 2), 93, 28),
    ]);
    final verySparse = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 4), 93, 28),
    ]);

    expect(good.qualityLabel, 'Bom');
    expect(moderate.qualityLabel, 'Moderado');
    expect(sparse.qualityLabel, 'Esparso');
    expect(verySparse.qualityLabel, 'Muito esparso');
  });

  test('app state requests mock provider permissions safely', () async {
    final appState = AppState.fromRepository(const MockRiskRepository());

    final granted = await appState.requestCurrentProviderPermissions();

    expect(granted, isTrue);
    expect(appState.dataSourcePermissionGranted, isTrue);
    expect(appState.dataSourcePermissionMessage, 'Simulação ativa.');
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
    expect(find.text('Solicitar permissão'), findsOneWidget);
    expect(find.textContaining('Permissão:'), findsOneWidget);

    await tester.tap(find.text('HealthKit (experimental)'));
    await tester.pumpAndSettle();

    expect(find.text('Ler último dado'), findsOneWidget);
    expect(
      find.text('A coleta contínua ainda não está ativada.'),
      findsOneWidget,
    );

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
    expect(find.text('Protocolo guiado'), findsOneWidget);
    expect(find.text('Diagnóstico da coleta'), findsOneWidget);
    expect(find.text('Total de samples: 0'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Análise temporal'), 120);
    expect(find.text('Análise temporal'), findsOneWidget);
    expect(
      find.text('Aguardando mais amostras para calcular intervalos.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Diagnóstico bruto HealthKit'),
      120,
    );
    expect(find.text('Diagnóstico bruto HealthKit'), findsOneWidget);
    expect(
      find.text('Executar diagnóstico', skipOffstage: false),
      findsOneWidget,
    );

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sessão'));
    await tester.pumpAndSettle();

    expect(find.text('Sessão ativa'), findsOneWidget);
    expect(find.text('Amostras coletadas: 0'), findsOneWidget);

    await tester.tap(find.text('Iniciar simulação'));
    await tester.pumpAndSettle();

    expect(find.text('Amostras coletadas: 1'), findsOneWidget);
    expect(find.text('Total de samples: 1'), findsOneWidget);
    expect(find.text('Última amostra'), findsOneWidget);
  });

  testWidgets('guided protocol route starts and advances steps', (
    tester,
  ) async {
    await _pumpAppWithOnboardingSeen(tester);

    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modo pesquisa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Protocolo guiado'));
    await tester.pumpAndSettle();

    expect(find.text('Protocolo guiado'), findsOneWidget);
    expect(find.text('Iniciar protocolo'), findsOneWidget);

    await tester.tap(find.text('Iniciar protocolo'));
    await tester.pump();

    expect(find.text('Fase atual: Repouso'), findsOneWidget);
    expect(find.textContaining('Timer:'), findsOneWidget);
    expect(find.text('Samples nesta sessão: 1'), findsOneWidget);

    await tester.tap(find.text('Avançar etapa'));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('Fase atual: Ativação leve'), findsOneWidget);
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

  test('guided protocol starts advances labels samples and saves feedback', () {
    final appState = AppState.fromRepository(const MockRiskRepository());

    appState.startGuidedProtocol();

    expect(appState.hasActiveGuidedProtocol, isTrue);
    expect(appState.hasActiveResearchSession, isTrue);
    expect(appState.currentGuidedProtocolStep?.label, 'Repouso');
    expect(appState.currentResearchSession?.samples, hasLength(1));
    expect(
      appState.currentResearchSession?.samples.first.protocolStepLabel,
      'Repouso',
    );

    appState.stopSimulation();
    appState.advanceGuidedProtocolStep();
    appState.startSimulation();

    expect(appState.currentGuidedProtocolStep?.label, 'Ativação leve');
    expect(
      appState.currentResearchSession?.samples.last.protocolStepLabel,
      'Ativação leve',
    );

    appState.endGuidedProtocol(feedback: FeelingLevel.leve);

    expect(appState.hasActiveGuidedProtocol, isFalse);
    expect(appState.hasActiveResearchSession, isFalse);
    expect(appState.lastGuidedProtocolSession?.feedback, FeelingLevel.leve);
    expect(appState.lastGuidedProtocolSession?.samples, isNotEmpty);
    expect(appState.lastCalibrationFeedback?.feelingLevel, FeelingLevel.leve);
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
      'timestamp,heartRate,hrv,riskScore,riskState,motionState,protocolStepLabel\n2026-05-13T12:00:00.000,92,28,68,atencao,parado,',
    );
  });

  test('csv exporter includes protocol step label in research samples', () {
    const exporter = CsvExporter();
    final csv = exporter.exportSessionSamples([
      SessionSample(
        timestamp: DateTime(2026, 5, 13, 12),
        heartRate: 92,
        hrv: 28,
        riskScore: 68,
        riskState: RiskState.atencao,
        motionState: 'parado',
        protocolStepLabel: 'Repouso',
      ),
    ]);

    expect(csv, contains('protocolStepLabel'));
    expect(csv, contains('Repouso'));
  });

  test('csv exporter writes collection diagnostics', () {
    const exporter = CsvExporter();
    final diagnostics = CollectionDiagnostics.empty(sourceLabel: 'HealthKit')
        .addSample(_sessionSample(DateTime(2026, 5, 13, 12), 92, 28))
        .addSample(_sessionSample(DateTime(2026, 5, 13, 12, 0, 15), 94, 27))
        .skipDuplicate();

    final csv = exporter.exportCollectionDiagnostics(diagnostics);

    expect(
      csv,
      'totalSamples,heartRateSamples,hrvSamples,missingHeartRateCount,missingHrvCount,duplicateSamplesSkipped,firstSampleAt,lastSampleAt,averageIntervalSeconds,minIntervalSeconds,maxIntervalSeconds,sourceLabel\n2,2,2,0,0,1,2026-05-13T12:00:00.000,2026-05-13T12:00:15.000,15.0,15.0,15.0,HealthKit',
    );
  });

  test('csv exporter writes temporal analysis', () {
    const exporter = CsvExporter();
    final analysis = TemporalSampleAnalysis.fromSamples([
      _sessionSample(DateTime(2026, 5, 13, 12), 92, 28),
      _sessionSample(DateTime(2026, 5, 13, 12, 0, 30), 93, 27),
    ]);

    final csv = exporter.exportTemporalAnalysis(analysis);

    expect(
      csv,
      'totalSamples,firstSampleAt,lastSampleAt,durationSeconds,averageIntervalSeconds,medianIntervalSeconds,minIntervalSeconds,maxIntervalSeconds,longGapCount,longestGapSeconds,samplesPerMinute,qualityLabel\n2,2026-05-13T12:00:00.000,2026-05-13T12:00:30.000,30.0,30.0,30.0,30.0,30.0,0,30.0,4.0,Bom',
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

final class _NullHealthKitSensorProvider implements SensorProvider {
  @override
  SensorProviderType get type => SensorProviderType.healthkit;

  @override
  String get permissionStatusMessage =>
      'Nenhum dado recente encontrado no HealthKit.';

  @override
  Future<SensorSample?> getLatestSample() async {
    return null;
  }

  @override
  Future<bool> requestPermissions() async {
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    return true;
  }

  @override
  Stream<SensorSample> watchSamples() {
    return const Stream<SensorSample>.empty();
  }
}

final class _StreamHealthKitSensorProvider implements SensorProvider {
  final StreamController<SensorSample> _controller =
      StreamController<SensorSample>();

  bool isCanceled = false;

  @override
  SensorProviderType get type => SensorProviderType.healthkit;

  @override
  String get permissionStatusMessage => 'Permissão HealthKit concedida.';

  @override
  Future<SensorSample?> getLatestSample() async {
    return null;
  }

  @override
  Future<bool> requestPermissions() async {
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    return true;
  }

  @override
  Stream<SensorSample> watchSamples() {
    _controller.onCancel = () {
      isCanceled = true;
    };
    return _controller.stream;
  }

  void add(SensorSample sample) {
    if (!_controller.isClosed) {
      _controller.add(sample);
    }
  }

  Future<void> close() {
    return _controller.close();
  }
}

SensorSample _sample(
  String id,
  int heartRate,
  int hrv, {
  String motionState = 'parado',
}) {
  return SensorSample(
    id: id,
    timestamp: DateTime(2026),
    heartRate: heartRate,
    hrv: hrv,
    motionState: motionState,
  );
}

SessionSample _sessionSample(
  DateTime timestamp,
  int heartRate,
  int hrv, {
  String motionState = 'healthkit',
}) {
  return SessionSample(
    timestamp: timestamp,
    heartRate: heartRate,
    hrv: hrv,
    riskScore: 42,
    riskState: RiskState.normal,
    motionState: motionState,
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

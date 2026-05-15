import 'dart:async';

import 'package:flutter/widgets.dart';

import 'data/repositories/local_calibration_repository.dart';
import 'data/repositories/local_event_repository.dart';
import 'data/repositories/local_research_session_repository.dart';
import 'data/repositories/mock_risk_repository.dart';
import 'data/repositories/onboarding_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/sensors/healthkit_sensor_provider.dart';
import 'data/sensors/mock_sensor_provider.dart';
import 'data/sensors/sensor_provider.dart';
import 'domain/risk_engine.dart';
import 'domain/models/calibration_feedback.dart';
import 'domain/models/collection_diagnostics.dart';
import 'domain/models/experimental_insight.dart';
import 'domain/models/feeling_level.dart';
import 'domain/models/guided_protocol_analysis.dart';
import 'domain/models/guided_protocol.dart';
import 'domain/models/phase_analysis.dart';
import 'domain/models/research_session.dart';
import 'domain/models/risk_event.dart';
import 'domain/models/risk_state.dart';
import 'domain/models/sensor_sample.dart';
import 'domain/models/session_sample.dart';
import 'domain/models/sensitivity_level.dart';
import 'domain/models/temporal_sample_analysis.dart';

final class AppState extends ChangeNotifier {
  AppState({
    required SensorSample currentSample,
    required RiskState currentRiskState,
    required String currentStatusMessage,
    required List<RiskEvent> events,
    RiskEngine riskEngine = const RiskEngine(),
    LocalCalibrationRepository? localCalibrationRepository,
    LocalEventRepository? localEventRepository,
    LocalResearchSessionRepository? localResearchSessionRepository,
    OnboardingRepository? onboardingRepository,
    SettingsRepository? settingsRepository,
    SensorProvider? sensorProvider,
    bool loadPersistedCalibrationFeedbacks = true,
    bool loadPersistedEvents = true,
    bool loadPersistedResearchSessions = true,
    bool loadPersistedSettings = true,
    List<SensorSample> recentSamples = const [],
  }) : _riskEngine = riskEngine,
       _localCalibrationRepository =
           localCalibrationRepository ?? const LocalCalibrationRepository(),
       _localEventRepository =
           localEventRepository ?? const LocalEventRepository(),
       _localResearchSessionRepository =
           localResearchSessionRepository ??
           const LocalResearchSessionRepository(),
       _onboardingRepository =
           onboardingRepository ?? const OnboardingRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       _sensorProvider = sensorProvider ?? MockSensorProvider(),
       _currentSample = currentSample,
       _currentRiskState = currentRiskState,
       _currentStatusMessage = currentStatusMessage,
       _events = List.of(events),
       _recentSamples = List.of(recentSamples).length <= 30
           ? List.of(recentSamples)
           : List.of(recentSamples).sublist(recentSamples.length - 30) {
    _dataSourcePermissionGranted =
        _sensorProvider.type == SensorProviderType.mock;
    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    _applyRiskEvaluation(_currentSample);
    if (loadPersistedEvents) {
      unawaited(loadEvents());
    }
    if (loadPersistedCalibrationFeedbacks) {
      unawaited(loadCalibrationFeedbacks());
    }
    if (loadPersistedResearchSessions) {
      unawaited(loadResearchSessions());
    }
    if (loadPersistedSettings) {
      unawaited(loadSettings());
    }
  }

  factory AppState.fromRepository(MockRiskRepository repository) {
    return AppState(
      currentSample: repository.getCurrentSample(),
      currentRiskState: repository.getCurrentRiskState(),
      currentStatusMessage: repository.getCurrentStatusMessage(),
      events: repository.getRecentEvents(),
    );
  }

  final RiskEngine _riskEngine;
  final LocalCalibrationRepository _localCalibrationRepository;
  final LocalEventRepository _localEventRepository;
  final LocalResearchSessionRepository _localResearchSessionRepository;
  final OnboardingRepository _onboardingRepository;
  final SettingsRepository _settingsRepository;
  SensorProvider _sensorProvider;
  SensorSample _currentSample;
  SensorSample? _lastHealthKitSample;
  RiskState _currentRiskState;
  int _currentScore = 0;
  String _currentStatusMessage;
  bool _dataSourcePermissionGranted = true;
  String _dataSourcePermissionMessage = 'Simulação ativa.';
  String _healthKitDebugStatus = 'Diagnóstico HealthKit ainda não executado.';
  bool _isHealthKitDebugRunning = false;
  SensorSample? _lastPipelineEmittedSample;
  SessionSample? _lastPipelineSavedSample;
  SensorSample? _lastPipelineIgnoredSample;
  String _lastPipelineIgnoreReason = 'Nenhum descarte registrado.';
  int _emittedSamples = 0;
  int _savedSamples = 0;
  int _ignoredSamples = 0;
  final List<RiskEvent> _events;
  final List<SensorSample> _recentSamples;
  final List<int> _recentScores = [];
  RiskEvent? _activeEvent;
  Timer? _simulationTimer;
  Timer? _healthKitSessionFallbackTimer;
  StreamSubscription<SensorSample>? _healthKitSampleSubscription;
  bool _hasPendingAlert = false;
  bool _isDisposed = false;
  SensitivityLevel _sensitivity = SensitivityLevel.media;
  ResearchSession? _currentResearchSession;
  final GuidedProtocol _guidedProtocol = GuidedProtocol.initial();
  GuidedProtocolSession? _currentGuidedProtocolSession;
  GuidedProtocolSession? _lastGuidedProtocolSession;
  CollectionDiagnostics _collectionDiagnostics = CollectionDiagnostics.empty(
    sourceLabel: 'Simulação',
  );
  final List<CalibrationFeedback> _calibrationFeedbacks = [];
  final List<ResearchSession> _researchSessions = [];

  SensorSample get currentSample => _currentSample;
  SensorSample? get lastHealthKitSample => _lastHealthKitSample;
  bool get hasLoadedHealthKitSample => _lastHealthKitSample != null;
  bool get lastHealthKitSampleHasRealHrv =>
      !(_lastHealthKitSample?.id.endsWith('-fc-only') ?? false);
  RiskState get currentRiskState => _currentRiskState;
  int get currentScore => _currentScore;
  String get currentStatusMessage => _currentStatusMessage;
  List<RiskEvent> get events => List.unmodifiable(_events);
  List<SensorSample> get recentSamples => List.unmodifiable(_recentSamples);
  List<int> get recentScores => List.unmodifiable(_recentScores);
  int get baselineHeartRate => _calculateBaselineHeartRate();
  int get baselineHrv => _calculateBaselineHrv();
  RiskEvent? get activeEvent => _activeEvent;
  bool get isSimulationRunning => _simulationTimer?.isActive ?? false;
  bool get hasPendingAlert => _hasPendingAlert;
  SensitivityLevel get sensitivity => _sensitivity;
  SensorProviderType get sensorProviderType => _sensorProvider.type;
  bool get isHealthKitInPreparation =>
      _sensorProvider.type == SensorProviderType.healthkit;
  bool get dataSourcePermissionGranted => _dataSourcePermissionGranted;
  String get dataSourcePermissionMessage => _dataSourcePermissionMessage;
  String get healthKitDebugStatus => _healthKitDebugStatus;
  bool get isHealthKitDebugRunning => _isHealthKitDebugRunning;
  SensorSample? get lastPipelineEmittedSample => _lastPipelineEmittedSample;
  SessionSample? get lastPipelineSavedSample => _lastPipelineSavedSample;
  SensorSample? get lastPipelineIgnoredSample => _lastPipelineIgnoredSample;
  String get lastPipelineIgnoreReason => _lastPipelineIgnoreReason;
  int get emittedSamples => _emittedSamples;
  int get savedSamples => _savedSamples;
  int get ignoredSamples => _ignoredSamples;
  ResearchSession? get currentResearchSession => _currentResearchSession;
  bool get hasActiveResearchSession =>
      _currentResearchSession?.isActive ?? false;
  GuidedProtocol get guidedProtocol => _guidedProtocol;
  GuidedProtocolSession? get currentGuidedProtocolSession =>
      _currentGuidedProtocolSession;
  GuidedProtocolSession? get lastGuidedProtocolSession =>
      _lastGuidedProtocolSession;
  bool get hasActiveGuidedProtocol =>
      _currentGuidedProtocolSession?.isActive ?? false;
  GuidedProtocolStep? get currentGuidedProtocolStep {
    final session = _currentGuidedProtocolSession;
    if (session == null || _guidedProtocol.steps.isEmpty) {
      return null;
    }

    return _guidedProtocol.steps[session.currentStepIndex.clamp(
      0,
      _guidedProtocol.steps.length - 1,
    )];
  }

  bool get isHealthKitSessionCollectionActive =>
      _healthKitSampleSubscription != null;
  int get activeResearchSessionSampleCount =>
      _currentResearchSession?.samples.length ?? 0;
  DateTime? get lastResearchSessionSampleTimestamp =>
      _currentResearchSession?.samples.lastOrNull?.timestamp;
  CollectionDiagnostics get collectionDiagnostics => _collectionDiagnostics;
  TemporalSampleAnalysis get currentTemporalAnalysis =>
      TemporalSampleAnalysis.fromSamples(
        _currentResearchSession?.samples ?? const [],
      );
  TemporalSampleAnalysis get lastClosedSessionTemporalAnalysis =>
      TemporalSampleAnalysis.fromSamples(
        _researchSessions.firstOrNull?.samples ?? const [],
      );
  List<CalibrationFeedback> get calibrationFeedbacks =>
      List.unmodifiable(_calibrationFeedbacks);
  CalibrationFeedback? get lastCalibrationFeedback =>
      _calibrationFeedbacks.firstOrNull;
  List<ResearchSession> get researchSessions =>
      List.unmodifiable(_researchSessions);
  ResearchSession? get lastResearchSession => _researchSessions.firstOrNull;
  GuidedProtocolAnalysis get currentGuidedProtocolAnalysis =>
      GuidedProtocolAnalysis.fromSamples(
        _currentGuidedProtocolSession?.samples ??
            _currentResearchSession?.samples ??
            const [],
      );
  GuidedProtocolAnalysis get lastGuidedProtocolAnalysis =>
      GuidedProtocolAnalysis.fromSamples(
        _lastGuidedProtocolSession?.samples ?? const [],
      );
  List<ExperimentalInsight> get currentExperimentalInsights =>
      _buildExperimentalInsights(
        _currentGuidedProtocolSession?.samples ??
            _currentResearchSession?.samples ??
            const [],
      );
  List<ExperimentalInsight> get lastExperimentalInsights =>
      _buildExperimentalInsights(
        _lastGuidedProtocolSession?.samples ??
            _researchSessions.firstOrNull?.samples ??
            const [],
      );

  Future<void> loadEvents() async {
    final persistedEvents = await _localEventRepository.loadEvents();
    if (_isDisposed || persistedEvents.isEmpty) {
      return;
    }

    _events
      ..clear()
      ..addAll(persistedEvents);
    notifyListeners();
  }

  Future<void> loadCalibrationFeedbacks() async {
    final persistedFeedbacks = await _localCalibrationRepository
        .loadFeedbacks();
    if (_isDisposed || persistedFeedbacks.isEmpty) {
      return;
    }

    _calibrationFeedbacks
      ..clear()
      ..addAll(persistedFeedbacks);
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final sensitivity = await _settingsRepository.loadSensitivity();
    if (_isDisposed) {
      return;
    }

    _sensitivity = sensitivity;
    _applyRiskEvaluation(_currentSample);
    notifyListeners();
  }

  Future<void> loadResearchSessions() async {
    final persistedSessions = await _localResearchSessionRepository
        .loadSessions();
    if (_isDisposed || persistedSessions.isEmpty) {
      return;
    }

    _researchSessions
      ..clear()
      ..addAll(persistedSessions);
    notifyListeners();
  }

  Future<void> updateSensitivity(SensitivityLevel sensitivity) async {
    _sensitivity = sensitivity;
    _applyRiskEvaluation(_currentSample);
    notifyListeners();
    await _settingsRepository.saveSensitivity(sensitivity);
  }

  void updateSensorProvider(SensorProviderType type) {
    if (_sensorProvider.type == type) {
      return;
    }

    stopSimulation();
    _stopHealthKitSessionCollection();
    _sensorProvider = switch (type) {
      SensorProviderType.mock => MockSensorProvider(),
      SensorProviderType.healthkit => HealthKitSensorProvider(),
    };
    _dataSourcePermissionGranted = type == SensorProviderType.mock;
    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    if (type == SensorProviderType.healthkit) {
      _currentStatusMessage =
          'HealthKit selecionado. Carregue o último dado disponível ou use a simulação quando preferir.';
    } else {
      _lastHealthKitSample = null;
      _applyRiskEvaluation(_currentSample);
    }
    notifyListeners();
  }

  Future<bool> requestCurrentProviderPermissions() async {
    final granted = await _sensorProvider.requestPermissions();
    if (_isDisposed) {
      return granted;
    }

    _dataSourcePermissionGranted = granted;
    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    notifyListeners();
    return granted;
  }

  Future<bool> loadLatestHealthKitSample() async {
    if (_sensorProvider.type != SensorProviderType.healthkit) {
      return false;
    }

    final sample = await _sensorProvider.getLatestSample();
    if (_isDisposed) {
      return sample != null;
    }

    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    if (sample == null) {
      _currentStatusMessage = _dataSourcePermissionMessage.contains('Permissão')
          ? 'Permissão HealthKit necessária.'
          : 'Nenhum dado recente encontrado.';
      notifyListeners();
      return false;
    }

    _lastHealthKitSample = sample;
    _applySensorSample(sample);
    _currentStatusMessage = 'Último dado do HealthKit carregado.';
    notifyListeners();
    return true;
  }

  Future<void> runHealthKitDebugDiagnostics() async {
    if (_sensorProvider is! HealthKitSensorProvider) {
      _healthKitDebugStatus =
          'Selecione HealthKit experimental para executar o diagnóstico.';
      notifyListeners();
      return;
    }

    _isHealthKitDebugRunning = true;
    _healthKitDebugStatus = 'Executando diagnóstico HealthKit...';
    notifyListeners();

    final provider = _sensorProvider as HealthKitSensorProvider;
    final status = await provider.debugHealthKitStatus();
    if (_isDisposed) {
      return;
    }

    _dataSourcePermissionMessage = provider.permissionStatusMessage;
    _healthKitDebugStatus = status;
    _isHealthKitDebugRunning = false;
    notifyListeners();
  }

  void startSimulation() {
    if (isSimulationRunning) {
      return;
    }

    _requestNextSensorSample();
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _requestNextSensorSample(),
    );
    notifyListeners();
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _events.clear();
    _calibrationFeedbacks.clear();
    _researchSessions.clear();
    await _persistEvents();
    await _persistCalibrationFeedbacks();
    await _persistResearchSessions();
    notifyListeners();
  }

  Future<void> resetOnboarding() {
    return _onboardingRepository.resetOnboarding();
  }

  void startResearchSession() {
    final now = DateTime.now();
    _resetSessionPipelineDebug();
    _currentResearchSession = ResearchSession(
      id: 'research-${now.microsecondsSinceEpoch}',
      startedAt: now,
      samples: const [],
    );
    _collectionDiagnostics = CollectionDiagnostics.empty(
      sourceLabel: _diagnosticsSourceLabel,
    );
    _pipelineLog(
      'Sessão iniciada id=${_currentResearchSession!.id} '
      'provider=$_diagnosticsSourceLabel.',
    );
    _startHealthKitSessionCollectionForActiveSession();
    notifyListeners();
  }

  void endResearchSession({String? notes}) {
    final session = _currentResearchSession;
    if (session == null || !session.isActive) {
      return;
    }

    final endedSession = session.copyWith(
      endedAt: DateTime.now(),
      notes: notes,
    );
    _pipelineLog(
      'Sessão encerrada id=${session.id} samples=${session.samples.length} '
      'emitted=$_emittedSamples saved=$_savedSamples ignored=$_ignoredSamples.',
    );
    _stopHealthKitSessionCollection();
    _currentResearchSession = endedSession;
    _researchSessions.insert(0, endedSession);
    _completeGuidedProtocolFromResearchSession(endedSession);
    unawaited(_persistResearchSessions());
    notifyListeners();
  }

  void startGuidedProtocol() {
    if (hasActiveGuidedProtocol) {
      return;
    }

    final now = DateTime.now();
    _currentGuidedProtocolSession = GuidedProtocolSession(
      id: 'guided-${now.microsecondsSinceEpoch}',
      protocolId: _guidedProtocol.id,
      startedAt: now,
      currentStepIndex: 0,
      stepStartedAt: now,
      samples: const [],
    );

    if (!hasActiveResearchSession) {
      startResearchSession();
    }
    if (_sensorProvider.type == SensorProviderType.mock &&
        !isSimulationRunning) {
      startSimulation();
    } else {
      _startHealthKitSessionCollectionIfNeeded();
      notifyListeners();
    }
  }

  void advanceGuidedProtocolStep() {
    final session = _currentGuidedProtocolSession;
    if (session == null || !session.isActive) {
      return;
    }

    final nextIndex = (session.currentStepIndex + 1).clamp(
      0,
      _guidedProtocol.steps.length - 1,
    );
    _currentGuidedProtocolSession = session.copyWith(
      currentStepIndex: nextIndex,
      stepStartedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void submitGuidedProtocolFeedback(FeelingLevel feelingLevel) {
    final session = _currentGuidedProtocolSession;
    if (session == null) {
      return;
    }

    _currentGuidedProtocolSession = session.copyWith(feedback: feelingLevel);
    notifyListeners();
  }

  void endGuidedProtocol({FeelingLevel? feedback}) {
    if (feedback != null) {
      submitGuidedProtocolFeedback(feedback);
    }

    final finalFeedback = _currentGuidedProtocolSession?.feedback;
    if (finalFeedback != null) {
      addCalibrationFeedback(finalFeedback);
    }

    if (hasActiveResearchSession) {
      endResearchSession(notes: 'Protocolo guiado');
      return;
    }

    final session = _currentGuidedProtocolSession;
    if (session == null) {
      return;
    }

    _lastGuidedProtocolSession = session.copyWith(endedAt: DateTime.now());
    _currentGuidedProtocolSession = null;
    notifyListeners();
  }

  void addCalibrationFeedback(FeelingLevel feelingLevel) {
    final now = DateTime.now();
    final feedback = CalibrationFeedback(
      id: 'calibration-${now.microsecondsSinceEpoch}',
      timestamp: now,
      feelingLevel: feelingLevel,
      label: feelingLevel.label,
      heartRate: _currentSample.heartRate,
      hrv: _currentSample.hrv,
      riskScore: _currentScore,
      riskState: _currentRiskState,
    );

    _calibrationFeedbacks.insert(0, feedback);
    unawaited(_persistCalibrationFeedbacks());
    notifyListeners();
  }

  void startManualIntervention() {
    _hasPendingAlert = false;
    _activeEvent = _buildEvent(
      title: 'Intervenção manual',
      state: RiskState.atencao,
      maxScore: 60,
      description:
          'Regulação iniciada manualmente ao perceber sinais de ativação em atenção.',
    );
    notifyListeners();
  }

  void startGuidedRegulation() {
    startAlertIntervention();
  }

  void startAlertIntervention() {
    const maxScore = 75;
    _hasPendingAlert = false;
    _activeEvent = _buildEvent(
      title: 'Alerta automático',
      state: RiskState.alerta,
      maxScore: maxScore,
      description: 'Regulação iniciada a partir de sinais de ativação.',
    );
    _currentRiskState = RiskState.alerta;
    if (_currentScore < maxScore) {
      _currentScore = maxScore;
    }
    _currentStatusMessage =
        'Seu corpo apresentou sinais de ativação. Uma regulação curta pode ajudar agora.';
    notifyListeners();
  }

  void dismissPendingAlert() {
    if (!_hasPendingAlert) {
      return;
    }

    _events.insert(
      0,
      _buildEvent(
        title: 'Alerta observado',
        state: RiskState.alerta,
        maxScore: _currentScore,
        description:
            'Sinais de ativação foram registrados, mas a pessoa informou estar bem.',
      ).copyWith(
        endedAt: DateTime.now(),
        afterHeartRate: _currentSample.heartRate,
        afterHrv: _currentSample.hrv,
        feedback: 'Estou bem',
      ),
    );
    _hasPendingAlert = false;
    unawaited(_persistEvents());
    notifyListeners();
  }

  void completeActiveEvent(String feedback) {
    final activeEvent = _activeEvent;
    if (activeEvent == null) {
      return;
    }

    final completedEvent = activeEvent.copyWith(
      endedAt: DateTime.now(),
      afterHeartRate: (_currentSample.heartRate - 12).clamp(60, 220).toInt(),
      afterHrv: _currentSample.hrv + 8,
      feedback: feedback,
    );

    final existingIndex = _events.indexWhere(
      (event) => event.id == completedEvent.id,
    );
    if (existingIndex == -1) {
      _events.insert(0, completedEvent);
    } else {
      _events[existingIndex] = completedEvent;
    }
    unawaited(_persistEvents());

    final now = DateTime.now();
    _currentSample = SensorSample(
      id: 'sample-after-${now.microsecondsSinceEpoch}',
      timestamp: now,
      heartRate: completedEvent.afterHeartRate ?? _currentSample.heartRate,
      hrv: completedEvent.afterHrv ?? _currentSample.hrv,
      motionState: _currentSample.motionState,
    );
    _applyRiskEvaluation(_currentSample);
    _activeEvent = null;
    _hasPendingAlert = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _simulationTimer?.cancel();
    _stopHealthKitSessionCollection();
    _cancelHealthKitSessionFallback();
    super.dispose();
  }

  RiskEvent _buildEvent({
    required String title,
    required RiskState state,
    required int maxScore,
    required String description,
  }) {
    final now = DateTime.now();

    return RiskEvent(
      id: 'event-${now.microsecondsSinceEpoch}',
      startedAt: now,
      state: state,
      maxScore: maxScore,
      beforeHeartRate: _currentSample.heartRate,
      beforeHrv: _currentSample.hrv,
      title: title,
      description: description,
      feedback: '',
    );
  }

  void _requestNextSensorSample() {
    final provider = _sensorProvider;
    if (provider is MockSensorProvider) {
      final sample = provider.nextSample();
      _recordPipelineEmission(sample, source: 'mock.nextSample');
      _applySensorSample(sample);
      notifyListeners();
      return;
    }

    unawaited(_applyNextSensorSample());
  }

  Future<void> _applyNextSensorSample() async {
    final sample = await _sensorProvider.getLatestSample();
    if (_isDisposed) {
      return;
    }

    if (sample == null) {
      _recordPipelineMiss('provider retornou null em leitura avulsa');
      _currentStatusMessage =
          _sensorProvider.type == SensorProviderType.healthkit
          ? 'Nenhum dado recente encontrado no HealthKit.'
          : _currentStatusMessage;
      notifyListeners();
      return;
    }

    _recordPipelineEmission(sample, source: 'provider.getLatestSample');
    _applySensorSample(sample);
    notifyListeners();
  }

  void _startHealthKitSessionCollectionIfNeeded() {
    if (_sensorProvider.type != SensorProviderType.healthkit) {
      _pipelineLog(
        'Stream HealthKit não iniciada: provider atual=$_diagnosticsSourceLabel.',
      );
      return;
    }

    if (_healthKitSampleSubscription != null) {
      _pipelineLog('Stream HealthKit não iniciada: stream já ativa.');
      return;
    }

    _pipelineLog(
      'Stream HealthKit iniciada. sessãoAtiva=$hasActiveResearchSession.',
    );
    _healthKitSampleSubscription = _sensorProvider.watchSamples().listen(
      (sample) {
        _recordPipelineEmission(sample, source: 'healthkit.watchSamples');
        _pipelineLog(
          'Sample recebido do provider: ${_describeSensorSample(sample)} '
          'sessãoAtiva=$hasActiveResearchSession.',
        );
        if (_isDisposed) {
          _recordPipelineIgnore(sample, 'AppState descartado');
          return;
        }
        if (!hasActiveResearchSession) {
          _recordPipelineIgnore(sample, 'sem sessão ativa');
          notifyListeners();
          return;
        }

        _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
        _applySensorSample(sample);
        _currentStatusMessage = 'Último dado do HealthKit carregado.';
        notifyListeners();
      },
      onError: (error) {
        if (_isDisposed) {
          return;
        }

        _recordPipelineIgnore(null, 'erro no stream HealthKit: $error');
        _currentStatusMessage =
            _dataSourcePermissionMessage.contains('Permissão')
            ? 'Permissão HealthKit necessária.'
            : 'Nenhum dado recente encontrado.';
        notifyListeners();
      },
    );
  }

  void _startHealthKitSessionCollectionForActiveSession() {
    if (_sensorProvider.type != SensorProviderType.healthkit) {
      _startHealthKitSessionCollectionIfNeeded();
      return;
    }

    if (!hasActiveResearchSession) {
      _pipelineLog('Stream HealthKit não reiniciada: sem sessão ativa.');
      return;
    }

    _pipelineLog('Reiniciando stream HealthKit para a sessão ativa.');
    _stopHealthKitSessionCollection();
    _resetProviderDeduplication();
    _startHealthKitSessionCollectionIfNeeded();
    unawaited(_loadImmediateHealthKitSessionSample());
    _scheduleHealthKitSessionFallback();
  }

  void _stopHealthKitSessionCollection() {
    if (_healthKitSampleSubscription == null) {
      _pipelineLog('Stream HealthKit cancelada: não havia stream ativa.');
      return;
    }

    _pipelineLog('Stream HealthKit cancelada.');
    unawaited(_healthKitSampleSubscription?.cancel());
    _healthKitSampleSubscription = null;
    _cancelHealthKitSessionFallback();
  }

  Future<void> _loadImmediateHealthKitSessionSample() async {
    if (_sensorProvider.type != SensorProviderType.healthkit ||
        !hasActiveResearchSession) {
      return;
    }

    _pipelineLog('Leitura imediata HealthKit iniciada para sessão ativa.');
    final sample = await _sensorProvider.getLatestSample();
    if (_isDisposed ||
        _sensorProvider.type != SensorProviderType.healthkit ||
        !hasActiveResearchSession) {
      return;
    }

    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    if (sample == null) {
      _recordPipelineMiss('leitura imediata HealthKit retornou null');
      notifyListeners();
      return;
    }

    _recordPipelineEmission(
      sample,
      source: 'healthkit.getLatestSample.immediate',
    );
    _applySensorSample(sample);
    _currentStatusMessage = 'Último dado do HealthKit carregado.';
    notifyListeners();
  }

  void _scheduleHealthKitSessionFallback() {
    _cancelHealthKitSessionFallback();
    _healthKitSessionFallbackTimer = Timer(const Duration(seconds: 30), () {
      if (_isDisposed ||
          _sensorProvider.type != SensorProviderType.healthkit ||
          !hasActiveResearchSession ||
          _savedSamples > 0) {
        return;
      }

      _pipelineLog(
        'Fallback HealthKit em 30s: nenhum sample salvo; tentando leitura avulsa.',
      );
      unawaited(_loadFallbackHealthKitSessionSample());
    });
  }

  Future<void> _loadFallbackHealthKitSessionSample() async {
    final sample = await _sensorProvider.getLatestSample();
    if (_isDisposed ||
        _sensorProvider.type != SensorProviderType.healthkit ||
        !hasActiveResearchSession ||
        _savedSamples > 0) {
      return;
    }

    _dataSourcePermissionMessage = _sensorProvider.permissionStatusMessage;
    if (sample == null) {
      _recordPipelineMiss('fallback HealthKit 30s retornou null');
      notifyListeners();
      return;
    }

    _recordPipelineEmission(
      sample,
      source: 'healthkit.getLatestSample.fallback30s',
    );
    _applySensorSample(sample);
    _currentStatusMessage = 'Último dado do HealthKit carregado.';
    notifyListeners();
  }

  void _cancelHealthKitSessionFallback() {
    _healthKitSessionFallbackTimer?.cancel();
    _healthKitSessionFallbackTimer = null;
  }

  void _resetProviderDeduplication() {
    final provider = _sensorProvider;
    if (provider is ResettableSensorDeduplication) {
      (provider as ResettableSensorDeduplication).resetDeduplication();
      _pipelineLog('Deduplicação do provider resetada.');
    }
  }

  void _applySensorSample(SensorSample sample) {
    _currentSample = sample;
    if (_sensorProvider.type == SensorProviderType.healthkit) {
      _lastHealthKitSample = sample;
    }
    _addRecentSample(sample);
    _applyRiskEvaluation(sample);
    _addRecentScore(_currentScore);
    _addSampleToResearchSession(sample);
  }

  void _applyRiskEvaluation(SensorSample sample) {
    final evaluation = _riskEngine.evaluate(
      sample,
      baselineHeartRate: baselineHeartRate,
      baselineHrv: baselineHrv,
      sensitivity: _sensitivity,
    );
    _currentRiskState = evaluation.state;
    _currentScore = evaluation.score;
    _currentStatusMessage = evaluation.message;
    if (evaluation.state == RiskState.alerta) {
      _hasPendingAlert = true;
    }
  }

  void _addRecentSample(SensorSample sample) {
    _recentSamples.add(sample);
    if (_recentSamples.length > 30) {
      _recentSamples.removeAt(0);
    }
  }

  void _addRecentScore(int score) {
    _recentScores.add(score);
    if (_recentScores.length > 30) {
      _recentScores.removeAt(0);
    }
  }

  void _addSampleToResearchSession(SensorSample sample) {
    final session = _currentResearchSession;
    if (session == null || !session.isActive) {
      _recordPipelineIgnore(sample, 'sem sessão ativa ao salvar');
      return;
    }

    final sessionSample = SessionSample(
      timestamp: sample.timestamp,
      heartRate: sample.heartRate,
      hrv: sample.hrv,
      riskScore: _currentScore,
      riskState: _currentRiskState,
      motionState: sample.motionState,
      protocolStepLabel: currentGuidedProtocolStep?.label,
    );

    final lastSample = session.samples.lastOrNull;
    if (lastSample != null && _isDuplicateSessionSample(lastSample, sample)) {
      _recordDuplicateSessionSample(lastSample, sample);
      _collectionDiagnostics = _collectionDiagnostics.skipDuplicate();
      return;
    }

    _collectionDiagnostics = _collectionDiagnostics.addSample(sessionSample);
    _currentResearchSession = session.copyWith(
      samples: [...session.samples, sessionSample],
    );
    _recordPipelineSave(sessionSample);
    _addSampleToGuidedProtocol(sessionSample);
  }

  void _addSampleToGuidedProtocol(SessionSample sample) {
    final protocolSession = _currentGuidedProtocolSession;
    if (protocolSession == null || !protocolSession.isActive) {
      return;
    }

    _currentGuidedProtocolSession = protocolSession.copyWith(
      samples: [...protocolSession.samples, sample],
    );
  }

  void _completeGuidedProtocolFromResearchSession(ResearchSession session) {
    final protocolSession = _currentGuidedProtocolSession;
    if (protocolSession == null) {
      return;
    }

    _lastGuidedProtocolSession = protocolSession.copyWith(
      endedAt: session.endedAt ?? DateTime.now(),
      samples: session.samples
          .where((sample) => sample.protocolStepLabel != null)
          .toList(),
    );
    _currentGuidedProtocolSession = null;
  }

  bool _isDuplicateSessionSample(
    SessionSample lastSample,
    SensorSample sample,
  ) {
    return lastSample.timestamp == sample.timestamp &&
        lastSample.heartRate == sample.heartRate &&
        lastSample.hrv == sample.hrv;
  }

  void _resetSessionPipelineDebug() {
    _lastPipelineEmittedSample = null;
    _lastPipelineSavedSample = null;
    _lastPipelineIgnoredSample = null;
    _lastPipelineIgnoreReason = 'Nenhum descarte registrado.';
    _emittedSamples = 0;
    _savedSamples = 0;
    _ignoredSamples = 0;
  }

  void _recordPipelineEmission(SensorSample sample, {required String source}) {
    _emittedSamples += 1;
    _lastPipelineEmittedSample = sample;
    _pipelineLog(
      'Sample emitido/recebido ($source): ${_describeSensorSample(sample)} '
      'totalEmitidos=$_emittedSamples.',
    );
  }

  void _recordPipelineSave(SessionSample sample) {
    _savedSamples += 1;
    _lastPipelineSavedSample = sample;
    _pipelineLog(
      'Sample salvo: ${_describeSessionSample(sample)} '
      'totalSalvos=$_savedSamples '
      'samplesSessão=${_currentResearchSession?.samples.length ?? 0}.',
    );
  }

  void _recordPipelineIgnore(SensorSample? sample, String reason) {
    _ignoredSamples += 1;
    _lastPipelineIgnoredSample = sample;
    _lastPipelineIgnoreReason = reason;
    _pipelineLog(
      'Sample ignorado: motivo="$reason" '
      'sample=${sample == null ? 'null' : _describeSensorSample(sample)} '
      'totalIgnorados=$_ignoredSamples.',
    );
  }

  void _recordPipelineMiss(String reason) {
    _lastPipelineIgnoreReason = reason;
    _pipelineLog('Nenhum sample para salvar: motivo="$reason".');
  }

  void _recordDuplicateSessionSample(
    SessionSample lastSample,
    SensorSample sample,
  ) {
    final sameTimestamp = lastSample.timestamp == sample.timestamp;
    final sameHeartRate = lastSample.heartRate == sample.heartRate;
    final sameHrv = lastSample.hrv == sample.hrv;
    _recordPipelineIgnore(
      sample,
      'duplicado: timestamp=$sameTimestamp FC=$sameHeartRate HRV=$sameHrv; '
      'anterior=${_describeSessionSample(lastSample)}',
    );
  }

  String _describeSensorSample(SensorSample sample) {
    return 'id=${sample.id} ts=${sample.timestamp.toIso8601String()} '
        'FC=${sample.heartRate} HRV=${sample.hrv} '
        'motion=${sample.motionState}';
  }

  String _describeSessionSample(SessionSample sample) {
    return 'ts=${sample.timestamp.toIso8601String()} '
        'FC=${sample.heartRate} HRV=${sample.hrv} '
        'score=${sample.riskScore} state=${sample.riskState.key} '
        'motion=${sample.motionState}';
  }

  void _pipelineLog(String message) {
    debugPrint('[SignalFlowSessionPipeline] $message');
  }

  List<ExperimentalInsight> _buildExperimentalInsights(
    List<SessionSample> samples,
  ) {
    if (samples.isEmpty) {
      return const [];
    }

    final protocolAnalysis = GuidedProtocolAnalysis.fromSamples(samples);
    final temporalAnalysis = TemporalSampleAnalysis.fromSamples(samples);
    final insights = <ExperimentalInsight>[];
    final rest = _phaseByLabel(protocolAnalysis, 'Repouso');
    final activation = _phaseByLabel(protocolAnalysis, 'Ativação leve');
    final recovery = _phaseByLabel(protocolAnalysis, 'Recuperação');

    if (rest != null &&
        activation != null &&
        activation.averageHeartRate > rest.averageHeartRate + 10) {
      final increase = activation.averageHeartRate - rest.averageHeartRate;
      insights.add(
        ExperimentalInsight(
          title: 'Sinais aumentaram na ativação',
          description:
              'Os sinais fisiológicos aumentaram durante a fase de ativação leve em comparação com o repouso.',
          category: InsightCategory.activation,
          confidenceLabel: _confidenceForPhaseSamples(
            rest.sampleCount + activation.sampleCount,
          ),
          valueSummary:
              'Repouso ${_formatInsightNumber(rest.averageHeartRate)} bpm -> ativação ${_formatInsightNumber(activation.averageHeartRate)} bpm (+${_formatInsightNumber(increase)} bpm)',
        ),
      );
    }

    if (activation != null &&
        recovery != null &&
        recovery.averageHeartRate < activation.averageHeartRate) {
      final reduction = activation.averageHeartRate - recovery.averageHeartRate;
      insights.add(
        ExperimentalInsight(
          title: 'Sinais reduziram na recuperação',
          description:
              'Os sinais fisiológicos reduziram durante a recuperação em comparação com a ativação leve.',
          category: InsightCategory.recovery,
          confidenceLabel: _confidenceForPhaseSamples(
            activation.sampleCount + recovery.sampleCount,
          ),
          valueSummary:
              'Ativação ${_formatInsightNumber(activation.averageHeartRate)} bpm -> recuperação ${_formatInsightNumber(recovery.averageHeartRate)} bpm (-${_formatInsightNumber(reduction)} bpm)',
        ),
      );
    }

    if (temporalAnalysis.totalSamples > 0 &&
        temporalAnalysis.samplesPerMinute < 0.5) {
      insights.add(
        ExperimentalInsight(
          title: 'Coleta muito esparsa',
          description:
              'A frequência dos dados foi muito esparsa nesta sessão, então os padrões devem ser lidos com cautela.',
          category: InsightCategory.collection,
          confidenceLabel: 'baixa',
          valueSummary:
              '${_formatInsightDecimal(temporalAnalysis.samplesPerMinute)} samples/min',
        ),
      );
    }

    if (samples.isNotEmpty && !samples.any(_hasAvailableHrv)) {
      insights.add(
        ExperimentalInsight(
          title: 'HRV indisponível',
          description:
              'Não houve dados HRV disponíveis nesta sessão. A leitura ficou baseada nas amostras de frequência cardíaca.',
          category: InsightCategory.collection,
          confidenceLabel: 'moderada',
          valueSummary: '0 samples HRV',
        ),
      );
    }

    if (protocolAnalysis.phases.isNotEmpty &&
        !protocolAnalysis.hasEnoughDataForCompleteAnalysis) {
      insights.add(
        ExperimentalInsight(
          title: 'Protocolo com dados parciais',
          description:
              'A sessão ainda não tem amostras suficientes em todas as fases para uma comparação completa.',
          category: InsightCategory.protocol,
          confidenceLabel: 'baixa',
          valueSummary:
              '${protocolAnalysis.totalSamples} samples com fase registrada',
        ),
      );
    }

    return List.unmodifiable(insights);
  }

  PhaseAnalysis? _phaseByLabel(GuidedProtocolAnalysis analysis, String label) {
    for (final phase in analysis.phases) {
      if (phase.stepLabel == label) {
        return phase;
      }
    }

    return null;
  }

  String _confidenceForPhaseSamples(int sampleCount) {
    if (sampleCount >= 10) {
      return 'alta';
    }

    if (sampleCount >= 4) {
      return 'moderada';
    }

    return 'baixa';
  }

  String _formatInsightNumber(double value) {
    return value.toStringAsFixed(0);
  }

  String _formatInsightDecimal(double value) {
    return value.toStringAsFixed(2);
  }

  bool _hasAvailableHrv(SessionSample sample) {
    return sample.motionState != 'healthkit-hrv-indisponivel' && sample.hrv > 0;
  }

  String get _diagnosticsSourceLabel {
    return switch (_sensorProvider.type) {
      SensorProviderType.mock => 'Simulação',
      SensorProviderType.healthkit => 'HealthKit',
    };
  }

  Future<void> _persistEvents() {
    return _localEventRepository.saveEvents(_events);
  }

  Future<void> _persistCalibrationFeedbacks() {
    return _localCalibrationRepository.saveFeedbacks(_calibrationFeedbacks);
  }

  Future<void> _persistResearchSessions() {
    return _localResearchSessionRepository.saveSessions(_researchSessions);
  }

  int _calculateBaselineHeartRate() {
    if (_recentSamples.length < 5) {
      return RiskEngine.fallbackHeartRate;
    }

    final total = _recentSamples.fold<int>(
      0,
      (sum, sample) => sum + sample.heartRate,
    );
    return (total / _recentSamples.length).round();
  }

  int _calculateBaselineHrv() {
    if (_recentSamples.length < 5) {
      return RiskEngine.fallbackHrv;
    }

    final total = _recentSamples.fold<int>(
      0,
      (sum, sample) => sum + sample.hrv,
    );
    return (total / _recentSamples.length).round();
  }
}

final class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    required AppState appState,
    required super.child,
    super.key,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope não encontrado na árvore.');
    return scope!.notifier!;
  }
}

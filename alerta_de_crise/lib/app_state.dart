import 'dart:async';

import 'package:flutter/widgets.dart';

import 'data/repositories/local_calibration_repository.dart';
import 'data/repositories/local_event_repository.dart';
import 'data/repositories/local_research_session_repository.dart';
import 'data/repositories/mock_risk_repository.dart';
import 'data/repositories/onboarding_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'domain/risk_engine.dart';
import 'domain/models/calibration_feedback.dart';
import 'domain/models/feeling_level.dart';
import 'domain/models/research_session.dart';
import 'domain/models/risk_event.dart';
import 'domain/models/risk_state.dart';
import 'domain/models/sensor_sample.dart';
import 'domain/models/session_sample.dart';
import 'domain/models/sensitivity_level.dart';

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
       _currentSample = currentSample,
       _currentRiskState = currentRiskState,
       _currentStatusMessage = currentStatusMessage,
       _events = List.of(events),
       _recentSamples = List.of(recentSamples).length <= 30
           ? List.of(recentSamples)
           : List.of(recentSamples).sublist(recentSamples.length - 30) {
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
  SensorSample _currentSample;
  RiskState _currentRiskState;
  int _currentScore = 0;
  String _currentStatusMessage;
  final List<RiskEvent> _events;
  final List<SensorSample> _recentSamples;
  final List<int> _recentScores = [];
  RiskEvent? _activeEvent;
  Timer? _simulationTimer;
  int _simulationIndex = 0;
  bool _hasPendingAlert = false;
  bool _isDisposed = false;
  SensitivityLevel _sensitivity = SensitivityLevel.media;
  ResearchSession? _currentResearchSession;
  final List<CalibrationFeedback> _calibrationFeedbacks = [];
  final List<ResearchSession> _researchSessions = [];

  SensorSample get currentSample => _currentSample;
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
  ResearchSession? get currentResearchSession => _currentResearchSession;
  bool get hasActiveResearchSession =>
      _currentResearchSession?.isActive ?? false;
  List<CalibrationFeedback> get calibrationFeedbacks =>
      List.unmodifiable(_calibrationFeedbacks);
  CalibrationFeedback? get lastCalibrationFeedback =>
      _calibrationFeedbacks.firstOrNull;
  List<ResearchSession> get researchSessions =>
      List.unmodifiable(_researchSessions);
  ResearchSession? get lastResearchSession => _researchSessions.firstOrNull;

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

  void startSimulation() {
    if (isSimulationRunning) {
      return;
    }

    _applyNextSimulatedSample();
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _applyNextSimulatedSample(),
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
    _currentResearchSession = ResearchSession(
      id: 'research-${now.microsecondsSinceEpoch}',
      startedAt: now,
      samples: const [],
    );
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
    _currentResearchSession = endedSession;
    _researchSessions.insert(0, endedSession);
    unawaited(_persistResearchSessions());
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

  void _applyNextSimulatedSample() {
    final samples = _simulatedSamples();
    final sample = samples[_simulationIndex % samples.length];
    _simulationIndex++;
    _currentSample = sample;
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
      return;
    }

    final sessionSample = SessionSample(
      timestamp: sample.timestamp,
      heartRate: sample.heartRate,
      hrv: sample.hrv,
      riskScore: _currentScore,
      riskState: _currentRiskState,
      motionState: sample.motionState,
    );

    _currentResearchSession = session.copyWith(
      samples: [...session.samples, sessionSample],
    );
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

  List<SensorSample> _simulatedSamples() {
    final now = DateTime.now();

    return [
      SensorSample(
        id: 'sim-normal-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 72,
        hrv: 42,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-leve-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 84,
        hrv: 34,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-atencao-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 94,
        hrv: 27,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-alerta-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 112,
        hrv: 18,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-recuperacao-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 80,
        hrv: 36,
        motionState: 'caminhando',
      ),
    ];
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

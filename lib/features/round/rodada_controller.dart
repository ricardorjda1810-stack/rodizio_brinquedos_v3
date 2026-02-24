// lib/features/round/rodada_controller.dart
import 'dart:async';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

import 'rodada_state.dart';

class RodadaController {
  final ToyRepository _toyRepository;
  final RoundRepository _roundRepository;
  final SettingsRepository _settingsRepository;

  final _stateController = StreamController<RoundViewState>.broadcast();

  StreamSubscription<List<Toy>>? _toysSub;
  StreamSubscription<Round?>? _activeRoundSub;
  StreamSubscription<int>? _roundSizeSub;
  Timer? _dayBoundaryTimer;

  List<Toy> _latestToys = const <Toy>[];
  Round? _latestActiveRound;
  int _roundSize = 7;

  int _sourceHash = 0;
  final Map<int, List<Toy>> _planByDay = <int, List<Toy>>{};

  DateTime? _selectedDate;

  RodadaController({
    required ToyRepository toyRepository,
    required RoundRepository roundRepository,
    required SettingsRepository settingsRepository,
  })  : _toyRepository = toyRepository,
        _roundRepository = roundRepository,
        _settingsRepository = settingsRepository {
    _roundSize = settingsRepository.roundSize;
  }

  Stream<RoundViewState> get stream => _stateController.stream;

  bool get _isPlanActive => _latestActiveRound != null;

  void init() {
    _emit();
    _scheduleNextDayBoundary();

    _toysSub = _toyRepository.watchAll().listen((items) {
      _latestToys = items;
      _emit();
    });

    _activeRoundSub = _roundRepository.watchActiveRound().listen((round) {
      _latestActiveRound = round;
      _emit();
    });

    _roundSizeSub = _settingsRepository.watchRoundSize().listen((size) {
      _roundSize = size;
      _emit();
    });
  }

  Future<void> ensurePlanForCurrentWeek() async {
    if (_isPlanActive) return;
    await _roundRepository.startRound(size: _roundSize);
  }

  void selectDay(DateTime date) {
    if (!_isPlanActive) return;

    final normalized = _normalizeDate(date);
    final weekStart = _currentWeekMonday(_todayLocal());
    final weekEnd = weekStart.add(const Duration(days: 6));

    if (normalized.isBefore(weekStart) || normalized.isAfter(weekEnd)) {
      return;
    }

    if (_selectedDate == normalized) return;

    _selectedDate = normalized;
    _emit();
  }

  void _emit() {
    if (_stateController.isClosed) return;

    final today = _todayLocal();
    final weekStart = _currentWeekMonday(today);
    final sortedToys = _sortForPlan(_latestToys);

    final nextSourceHash = Object.hash(
      _isPlanActive,
      _roundSize,
      weekStart,
      Object.hashAll(
        sortedToys.map((t) => Object.hash(t.id, t.name, t.createdAt, t.photoPath)),
      ),
    );

    if (_sourceHash != nextSourceHash) {
      _sourceHash = nextSourceHash;
      _planByDay.clear();
    }

    if (!_isPlanActive) {
      _selectedDate = null;
    } else {
      _selectedDate ??= today;
      if (_selectedDate!.isBefore(weekStart) ||
          _selectedDate!.isAfter(weekStart.add(const Duration(days: 6)))) {
        _selectedDate = today;
      }
      _ensurePlanCoverage(weekStart: weekStart, sortedToys: sortedToys);
    }

    const labels = <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekItems = List<RoundWeekItem>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return RoundWeekItem(
        date: date,
        weekdayLabel: labels[index],
        dayNumber: date.day.toString(),
        isToday: _isPlanActive && date == today,
        isSelected: _isPlanActive && date == _selectedDate,
      );
    });

    final toys = (_isPlanActive && _selectedDate != null)
        ? (_planByDay[_selectedDate!.millisecondsSinceEpoch] ?? const <Toy>[])
        : const <Toy>[];

    _stateController.add(
      RoundViewState(
        weekItems: weekItems,
        isPlanActive: _isPlanActive,
        selectedDate: _selectedDate,
        toys: toys,
        selectDay: selectDay,
      ),
    );
  }

  void _ensurePlanCoverage({
    required DateTime weekStart,
    required List<Toy> sortedToys,
  }) {
    final validKeys = <int>{};

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final key = date.millisecondsSinceEpoch;
      validKeys.add(key);

      _planByDay.putIfAbsent(key, () => _dailyPlanForOffset(sortedToys, i));
    }

    _planByDay.removeWhere((key, _) => !validKeys.contains(key));
  }

  List<Toy> _dailyPlanForOffset(List<Toy> sortedToys, int dayOffset) {
    if (sortedToys.isEmpty) return const <Toy>[];

    final count = _roundSize <= 0
        ? 0
        : (_roundSize > sortedToys.length ? sortedToys.length : _roundSize);

    if (count == 0) return const <Toy>[];

    final start = (dayOffset * count) % sortedToys.length;

    return List<Toy>.generate(count, (i) {
      final index = (start + i) % sortedToys.length;
      return sortedToys[index];
    });
  }

  List<Toy> _sortForPlan(List<Toy> items) {
    final list = List<Toy>.from(items);

    list.sort((a, b) {
      final aName = a.name.trim();
      final bName = b.name.trim();
      final aEmpty = aName.isEmpty;
      final bEmpty = bName.isEmpty;

      if (aEmpty && !bEmpty) return 1;
      if (!aEmpty && bEmpty) return -1;

      final byName = aName.toLowerCase().compareTo(bName.toLowerCase());
      if (byName != 0) return byName;

      return a.createdAt.compareTo(b.createdAt);
    });

    return list;
  }

  DateTime _todayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _currentWeekMonday(DateTime date) {
    final normalized = _normalizeDate(date);
    final offset = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: offset));
  }

  void _scheduleNextDayBoundary() {
    _dayBoundaryTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    final delay = nextDay.difference(now);

    _dayBoundaryTimer = Timer(delay, () {
      _emit();
      _scheduleNextDayBoundary();
    });
  }

  Future<void> dispose() async {
    await _toysSub?.cancel();
    await _activeRoundSub?.cancel();
    await _roundSizeSub?.cancel();
    _dayBoundaryTimer?.cancel();
    await _stateController.close();
  }
}


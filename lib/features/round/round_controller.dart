// lib/features/round/round_controller.dart
import 'dart:async';

import '../../data/db/app_database.dart';
import '../../data/repositories/round_repository.dart';
import 'round_state.dart';

/// UP (Um Único Produtor do Contrato):
/// - Produz tudo que a tela Rodada precisa:
///   rodada ativa + itens da rodada (toy + caixa).
/// - Centraliza operações: startRound, endActiveRound.
class RoundController {
  final RoundRepository _roundRepository;

  final _stateController = StreamController<RoundState>.broadcast();

  StreamSubscription<Round?>? _activeSub;
  StreamSubscription<List<RoundToyWithBox>>? _itemsSub;

  Round? _latestActive;
  List<RoundToyWithBox> _latestItems = const <RoundToyWithBox>[];

  RoundController({required RoundRepository roundRepository})
      : _roundRepository = roundRepository;

  Stream<RoundState> get stream => _stateController.stream;

  void init() {
    _emit();

    _activeSub = _roundRepository.watchActiveRound().listen((round) {
      _latestActive = round;
      _emit();
    });

    _itemsSub =
        _roundRepository.watchActiveRoundToysWithBox().listen((items) {
          _latestItems = items;
          _emit();
        });
  }

  void _emit() {
    if (_stateController.isClosed) return;
    _stateController.add(
      RoundState(
        activeRound: _latestActive,
        items: _latestItems,
      ),
    );
  }

  Future<void> startRound() async {
    await _roundRepository.startRound();
  }

  Future<void> endRound() async {
    await _roundRepository.endActiveRound();
  }

  Future<void> dispose() async {
    await _activeSub?.cancel();
    await _itemsSub?.cancel();
    await _stateController.close();
  }
}

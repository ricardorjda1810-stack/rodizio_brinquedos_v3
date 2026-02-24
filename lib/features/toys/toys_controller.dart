import 'dart:async';

import '../../data/repositories/toy_repository.dart';
import '../../data/db/app_database.dart';
import 'toys_state.dart';

/// UP (Um Único Produtor do Contrato):
/// - Produz tudo que a tela ToysPage precisa:
///   lista de brinquedos (com caixa) + lista de caixas + modo de ordenação.
/// - Centraliza operações.
class ToysController {
  final ToyRepository _toyRepository;

  final _stateController = StreamController<ToysState>.broadcast();

  StreamSubscription<List<ToyWithBox>>? _toysSub;
  StreamSubscription<List<Boxe>>? _boxesSub;

  List<ToyWithBox> _latestToys = const <ToyWithBox>[];
  List<Boxe> _latestBoxes = const <Boxe>[];

  ToysSortMode _sortMode = ToysSortMode.createdAsc;

  ToysController({required ToyRepository toyRepository})
      : _toyRepository = toyRepository;

  Stream<ToysState> get stream => _stateController.stream;

  ToysSortMode get sortMode => _sortMode;

  void init() {
    _emit();

    _toysSub = _toyRepository.watchAllWithBox().listen((items) {
      _latestToys = items;
      _emit();
    });

    _boxesSub = _toyRepository.watchBoxes().listen((items) {
      _latestBoxes = items;
      _emit();
    });
  }

  void setSortMode(ToysSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    _emit();
  }

  void _emit() {
    if (_stateController.isClosed) return;

    final sorted = _applySort(_latestToys, _sortMode);

    _stateController.add(
      ToysState(
        toys: sorted,
        boxes: _latestBoxes,
        sortMode: _sortMode,
      ),
    );
  }

  List<ToyWithBox> _applySort(List<ToyWithBox> items, ToysSortMode mode) {
    final list = List<ToyWithBox>.from(items);

    int cmpString(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

    switch (mode) {
      case ToysSortMode.createdAsc:
        list.sort((a, b) => a.toy.createdAt.compareTo(b.toy.createdAt));
        break;

      case ToysSortMode.createdDesc:
        list.sort((a, b) => b.toy.createdAt.compareTo(a.toy.createdAt));
        break;

      case ToysSortMode.nameAsc:
        list.sort((a, b) => cmpString(a.toy.name, b.toy.name));
        break;

      case ToysSortMode.nameDesc:
        list.sort((a, b) => cmpString(b.toy.name, a.toy.name));
        break;
    }

    return list;
  }

  Future<void> addToy({required String name, String? boxId}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _toyRepository.addToy(name: trimmed, boxId: boxId);
  }

  Future<void> setToyBox({required String toyId, String? boxId}) async {
    await _toyRepository.setToyBox(toyId: toyId, boxId: boxId);
  }

  Future<void> deleteAll() async {
    await _toyRepository.deleteAll();
  }

  Future<void> dispose() async {
    await _toysSub?.cancel();
    await _boxesSub?.cancel();
    await _stateController.close();
  }
}

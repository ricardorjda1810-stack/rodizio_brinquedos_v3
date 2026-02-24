// lib/features/boxes/boxes_controller.dart
import 'dart:async';

import '../../data/db/app_database.dart';
import '../../data/repositories/toy_repository.dart';
import 'boxes_state.dart';

/// UP (Um Único Produtor do Contrato):
/// Esta classe é a fonte única do estado/variáveis que a tela Caixas usa.
class BoxesController {
  final ToyRepository _toyRepository;

  final _stateController = StreamController<BoxesState>.broadcast();
  StreamSubscription<List<Boxe>>? _sub;

  List<Boxe> _latest = const <Boxe>[];

  BoxesController({required ToyRepository toyRepository})
      : _toyRepository = toyRepository;

  Stream<BoxesState> get stream => _stateController.stream;

  void init() {
    _emit();

    _sub = _toyRepository.watchBoxes().listen((boxes) {
      _latest = boxes;
      _emit();
    });
  }

  void _emit() {
    if (_stateController.isClosed) return;
    _stateController.add(BoxesState(boxes: _latest));
  }

  Future<void> addBox({required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _toyRepository.addBox(name: trimmed);
  }

  Future<void> deleteBox({required String boxId}) async {
    await _toyRepository.deleteBox(boxId: boxId);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _stateController.close();
  }
}

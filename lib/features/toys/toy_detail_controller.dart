// lib/features/toys/toy_detail_controller.dart
import 'dart:async';

import 'package:image_picker/image_picker.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/toy_repository.dart';
import 'toy_detail_state.dart';

class ToyDetailController {
  final ToyRepository _toyRepository;
  final String toyId;

  final _stateController = StreamController<ToyDetailState>.broadcast();

  StreamSubscription<ToyWithBox?>? _toySub;
  StreamSubscription<List<Boxe>>? _boxesSub;

  ToyWithBox? _latestToy;
  List<Boxe> _latestBoxes = const <Boxe>[];

  ToyDetailController({
    required ToyRepository toyRepository,
    required this.toyId,
  }) : _toyRepository = toyRepository;

  Stream<ToyDetailState> get stream => _stateController.stream;

  void init() {
    _emit();

    _toySub = _toyRepository.watchToyWithBox(toyId: toyId).listen((item) {
      _latestToy = item;
      _emit();
    });

    _boxesSub = _toyRepository.watchBoxes().listen((items) {
      _latestBoxes = items;
      _emit();
    });
  }

  void _emit() {
    if (_stateController.isClosed) return;
    _stateController.add(
      ToyDetailState(
        item: _latestToy,
        boxes: _latestBoxes,
      ),
    );
  }

  Future<void> setToyBox(String? boxId) async {
    await _toyRepository.setToyBox(toyId: toyId, boxId: boxId);
  }

  Future<void> pickPhoto(ImageSource source) async {
    await _toyRepository.pickAndSaveToyPhoto(toyId: toyId, source: source);
  }

  Future<void> removePhoto() async {
    await _toyRepository.removeToyPhoto(toyId: toyId);
  }

  Future<void> dispose() async {
    await _toySub?.cancel();
    await _boxesSub?.cancel();
    await _stateController.close();
  }
}

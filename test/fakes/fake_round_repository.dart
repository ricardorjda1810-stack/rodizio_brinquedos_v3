import 'dart:async';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';

class FakeRoundRepository extends RoundRepository {
  FakeRoundRepository() : super(null);

  final _roundController = StreamController<Round?>.broadcast();
  final _roundToysController =
  StreamController<List<RoundToyWithBox>>.broadcast();

  void emitRound(Round? round) {
    _roundController.add(round);
  }

  void emitRoundToys(List<RoundToyWithBox> items) {
    _roundToysController.add(items);
  }

  @override
  Stream<Round?> watchActiveRound() {
    return _roundController.stream;
  }

  @override
  Stream<List<RoundToyWithBox>> watchActiveRoundToysWithBox() {
    return _roundToysController.stream;
  }
}

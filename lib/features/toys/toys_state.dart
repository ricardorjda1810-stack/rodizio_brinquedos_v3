import '../../data/repositories/toy_repository.dart';
import '../../data/db/app_database.dart';

enum ToysSortMode {
  createdAsc,
  createdDesc,
  nameAsc,
  nameDesc,
}

String toysSortModeLabel(ToysSortMode mode) {
  switch (mode) {
    case ToysSortMode.createdAsc:
      return 'Mais antigos';
    case ToysSortMode.createdDesc:
      return 'Mais recentes';
    case ToysSortMode.nameAsc:
      return 'Nome (A–Z)';
    case ToysSortMode.nameDesc:
      return 'Nome (Z–A)';
  }
}

class ToysState {
  final List<ToyWithBox> toys;
  final List<Boxe> boxes;
  final ToysSortMode sortMode;

  const ToysState({
    required this.toys,
    required this.boxes,
    required this.sortMode,
  });

  bool get isEmpty => toys.isEmpty;

  static const empty = ToysState(
    toys: <ToyWithBox>[],
    boxes: <Boxe>[],
    sortMode: ToysSortMode.createdAsc,
  );
}

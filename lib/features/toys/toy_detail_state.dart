// lib/features/toys/toy_detail_state.dart
import '../../data/db/app_database.dart';
import '../../data/repositories/toy_repository.dart';

class ToyDetailState {
  final ToyWithBox? item;
  final List<Boxe> boxes;

  const ToyDetailState({
    required this.item,
    required this.boxes,
  });

  bool get notFound => item == null;

  static const empty = ToyDetailState(item: null, boxes: <Boxe>[]);
}

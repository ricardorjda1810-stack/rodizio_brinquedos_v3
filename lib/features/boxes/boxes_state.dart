// lib/features/boxes/boxes_state.dart
import '../../data/db/app_database.dart';

class BoxesState {
  final List<Boxe> boxes;

  const BoxesState({
    required this.boxes,
  });

  bool get isEmpty => boxes.isEmpty;

  static const empty = BoxesState(boxes: <Boxe>[]);
}

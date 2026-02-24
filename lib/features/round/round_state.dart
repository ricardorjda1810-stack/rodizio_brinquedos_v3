// lib/features/round/round_state.dart
import '../../data/db/app_database.dart';
import '../../data/repositories/round_repository.dart';

class RoundState {
  final Round? activeRound;
  final List<RoundToyWithBox> items;

  const RoundState({
    required this.activeRound,
    required this.items,
  });

  bool get hasActiveRound => activeRound != null;
  bool get hasItems => items.isNotEmpty;

  static const empty = RoundState(activeRound: null, items: <RoundToyWithBox>[]);
}

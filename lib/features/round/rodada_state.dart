// lib/features/round/rodada_state.dart
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

class RoundWeekItem {
  final DateTime date;
  final String weekdayLabel;
  final String dayNumber;
  final bool isToday;
  final bool isSelected;

  const RoundWeekItem({
    required this.date,
    required this.weekdayLabel,
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
  });
}

class RoundViewState {
  final List<RoundWeekItem> weekItems;
  final bool isPlanActive;
  final DateTime? selectedDate;
  final List<Toy> toys;
  final void Function(DateTime date) selectDay;

  const RoundViewState({
    required this.weekItems,
    required this.isPlanActive,
    required this.selectedDate,
    required this.toys,
    required this.selectDay,
  });

  static RoundViewState empty(void Function(DateTime date) selectDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - DateTime.monday));
    const labels = <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekItems = List<RoundWeekItem>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return RoundWeekItem(
        date: date,
        weekdayLabel: labels[index],
        dayNumber: date.day.toString(),
        isToday: false,
        isSelected: false,
      );
    });

    return RoundViewState(
      weekItems: weekItems,
      isPlanActive: false,
      selectedDate: null,
      toys: const <Toy>[],
      selectDay: selectDay,
    );
  }
}

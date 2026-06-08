class WeeklyPlanningOverviewCategoryInput {
  final String categoryId;
  final String categoryName;
  final bool isIncluded;
  final int quota;

  const WeeklyPlanningOverviewCategoryInput({
    required this.categoryId,
    required this.categoryName,
    required this.isIncluded,
    required this.quota,
  });

  int get safeQuota => quota < 0 ? 0 : quota;
}

class WeeklyPlanningOverviewToyInput {
  final String id;
  final String name;
  final String categoryId;
  final String? boxId;
  final String? photoPath;

  const WeeklyPlanningOverviewToyInput({
    required this.id,
    required this.name,
    required this.categoryId,
    this.boxId,
    this.photoPath,
  });
}

class WeeklyPlanningOverviewDayInput {
  final DateTime date;
  final int weekday;
  final String weekdayLabel;
  final List<WeeklyPlanningOverviewCategoryInput> categories;
  final List<WeeklyPlanningOverviewToyInput> toys;
  final bool isDefaultConfig;
  final bool isCustomConfig;

  const WeeklyPlanningOverviewDayInput({
    required this.date,
    required this.weekday,
    required this.weekdayLabel,
    required this.categories,
    required this.toys,
    required this.isDefaultConfig,
    required this.isCustomConfig,
  });
}

class WeeklyPlanningCategoryDistribution {
  final String categoryId;
  final String categoryName;
  final int total;

  const WeeklyPlanningCategoryDistribution({
    required this.categoryId,
    required this.categoryName,
    required this.total,
  });
}

class WeeklyPlanningDayOverview {
  final DateTime date;
  final int weekday;
  final String weekdayLabel;
  final List<WeeklyPlanningOverviewToyInput> toys;
  final int total;
  final bool isDefaultConfig;
  final bool isCustomConfig;

  const WeeklyPlanningDayOverview({
    required this.date,
    required this.weekday,
    required this.weekdayLabel,
    required this.toys,
    required this.total,
    required this.isDefaultConfig,
    required this.isCustomConfig,
  });

  int get missingToys => total > toys.length ? total - toys.length : 0;
  bool get hasInsufficientToys => missingToys > 0;
}

class WeeklyPlanningOverview {
  final bool planningEnabled;
  final int totalToysInWeek;
  final double averagePerDay;
  final int boxesInUse;
  final List<WeeklyPlanningCategoryDistribution> categoryDistribution;
  final List<WeeklyPlanningDayOverview> days;

  const WeeklyPlanningOverview({
    required this.planningEnabled,
    required this.totalToysInWeek,
    required this.averagePerDay,
    required this.boxesInUse,
    required this.categoryDistribution,
    required this.days,
  });

  bool get hasConfiguredToys => totalToysInWeek > 0;
  bool get hasInsufficientToys {
    return days.any((day) => day.hasInsufficientToys);
  }
}

WeeklyPlanningOverview buildWeeklyPlanningOverview({
  required bool planningEnabled,
  required List<WeeklyPlanningOverviewDayInput> days,
}) {
  final categoryTotals = <String, WeeklyPlanningCategoryDistribution>{};
  final boxesInUse = <String>{};
  var totalToysInWeek = 0;

  final dayOverviews = days.map((day) {
    var dailyTotal = 0;

    for (final category in day.categories) {
      if (!category.isIncluded || category.safeQuota <= 0) continue;
      dailyTotal += category.safeQuota;

      final current = categoryTotals[category.categoryId];
      categoryTotals[category.categoryId] = WeeklyPlanningCategoryDistribution(
        categoryId: category.categoryId,
        categoryName: category.categoryName,
        total: (current?.total ?? 0) + category.safeQuota,
      );
    }

    for (final toy in day.toys) {
      final boxId = toy.boxId?.trim();
      if (boxId != null && boxId.isNotEmpty) {
        boxesInUse.add(boxId);
      }
    }

    totalToysInWeek += dailyTotal;
    return WeeklyPlanningDayOverview(
      date: day.date,
      weekday: day.weekday,
      weekdayLabel: day.weekdayLabel,
      toys: day.toys,
      total: dailyTotal,
      isDefaultConfig: day.isDefaultConfig,
      isCustomConfig: day.isCustomConfig,
    );
  }).toList(growable: false);

  return WeeklyPlanningOverview(
    planningEnabled: planningEnabled,
    totalToysInWeek: totalToysInWeek,
    averagePerDay:
        dayOverviews.isEmpty ? 0 : totalToysInWeek / dayOverviews.length,
    boxesInUse: boxesInUse.length,
    categoryDistribution: categoryTotals.values.toList(growable: false),
    days: dayOverviews,
  );
}

DateTime startOfPlanningWeek(DateTime referenceDate) {
  final dateOnly = DateTime(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  return dateOnly.subtract(Duration(days: referenceDate.weekday - 1));
}

String weeklyPlanningWeekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Segunda';
    case DateTime.tuesday:
      return 'Terca';
    case DateTime.wednesday:
      return 'Quarta';
    case DateTime.thursday:
      return 'Quinta';
    case DateTime.friday:
      return 'Sexta';
    case DateTime.saturday:
      return 'Sabado';
    case DateTime.sunday:
      return 'Domingo';
    default:
      return 'Dia';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/weekly_planning_overview.dart';

void main() {
  test('calcula soma semanal, media por dia, categorias e caixas', () {
    final overview = buildWeeklyPlanningOverview(
      planningEnabled: true,
      days: List.generate(7, (index) {
        final weekday = index + 1;
        return WeeklyPlanningOverviewDayInput(
          date: DateTime(2026, 6, 8 + index),
          weekday: weekday,
          weekdayLabel: weeklyPlanningWeekdayLabel(weekday),
          categories: const [
            WeeklyPlanningOverviewCategoryInput(
              categoryId: 'faz_de_conta',
              categoryName: 'Faz de Conta',
              isIncluded: true,
              quota: 1,
            ),
            WeeklyPlanningOverviewCategoryInput(
              categoryId: 'movimento',
              categoryName: 'Movimento',
              isIncluded: true,
              quota: 2,
            ),
            WeeklyPlanningOverviewCategoryInput(
              categoryId: 'livros',
              categoryName: 'Historias',
              isIncluded: false,
              quota: 4,
            ),
          ],
          toys: [
            WeeklyPlanningOverviewToyInput(
              id: 'toy_$weekday-a',
              name: 'Toy A',
              categoryId: 'faz_de_conta',
              boxId: 'box_a',
            ),
            WeeklyPlanningOverviewToyInput(
              id: 'toy_$weekday-b',
              name: 'Toy B',
              categoryId: 'movimento',
              boxId: weekday.isEven ? 'box_b' : 'box_a',
            ),
          ],
          isDefaultConfig: true,
          isCustomConfig: false,
        );
      }),
    );

    expect(overview.totalToysInWeek, 21);
    expect(overview.averagePerDay, 3);
    expect(overview.boxesInUse, 2);
    expect(overview.categoryDistribution, hasLength(2));
    expect(overview.categoryDistribution[0].categoryId, 'faz_de_conta');
    expect(overview.categoryDistribution[0].total, 7);
    expect(overview.categoryDistribution[1].categoryId, 'movimento');
    expect(overview.categoryDistribution[1].total, 14);
  });

  test('preserva dias com configuracao padrao e personalizada', () {
    final overview = buildWeeklyPlanningOverview(
      planningEnabled: true,
      days: [
        _day(
          weekday: DateTime.monday,
          isDefaultConfig: false,
          isCustomConfig: true,
        ),
        _day(
          weekday: DateTime.tuesday,
          isDefaultConfig: true,
          isCustomConfig: false,
        ),
      ],
    );

    expect(overview.days[0].isCustomConfig, isTrue);
    expect(overview.days[0].isDefaultConfig, isFalse);
    expect(overview.days[1].isCustomConfig, isFalse);
    expect(overview.days[1].isDefaultConfig, isTrue);
  });

  test('marca brinquedos insuficientes sem alterar total derivado', () {
    final overview = buildWeeklyPlanningOverview(
      planningEnabled: true,
      days: [
        _day(
          weekday: DateTime.monday,
          quota: 5,
          toys: const [
            WeeklyPlanningOverviewToyInput(
              id: 'toy_1',
              name: 'Toy 1',
              categoryId: 'movimento',
            ),
            WeeklyPlanningOverviewToyInput(
              id: 'toy_2',
              name: 'Toy 2',
              categoryId: 'movimento',
            ),
          ],
        ),
      ],
    );

    expect(overview.totalToysInWeek, 5);
    expect(overview.days.single.total, 5);
    expect(overview.days.single.toys, hasLength(2));
    expect(overview.days.single.missingToys, 3);
    expect(overview.hasInsufficientToys, isTrue);
  });
}

WeeklyPlanningOverviewDayInput _day({
  required int weekday,
  int quota = 1,
  List<WeeklyPlanningOverviewToyInput> toys = const [],
  bool isDefaultConfig = true,
  bool isCustomConfig = false,
}) {
  return WeeklyPlanningOverviewDayInput(
    date: DateTime(2026, 6, 7 + weekday),
    weekday: weekday,
    weekdayLabel: weeklyPlanningWeekdayLabel(weekday),
    categories: [
      WeeklyPlanningOverviewCategoryInput(
        categoryId: 'movimento',
        categoryName: 'Movimento',
        isIncluded: true,
        quota: quota,
      ),
    ],
    toys: toys,
    isDefaultConfig: isDefaultConfig,
    isCustomConfig: isCustomConfig,
  );
}

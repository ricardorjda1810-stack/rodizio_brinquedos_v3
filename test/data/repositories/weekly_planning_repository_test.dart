import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;
  late WeeklyPlanningRepository weeklyPlanningRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: SettingsRepository(db),
    );
    await toyRepository.ensureSeedData();
    await toyRepository.restoreRoundCategoryDefaults();
  });

  tearDown(() async {
    await db.close();
  });

  test('restaurar planejamento deixa todos os dias com 7 brinquedos', () async {
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'veiculos',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'bonecos',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'montagem',
      quota: 5,
    );
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.monday,
      useDefault: false,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'veiculos',
      isIncluded: true,
      quota: 3,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'bonecos',
      isIncluded: true,
      quota: 3,
    );
    await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
          WeeklyPlanningSettingsCompanion.insert(
            weekday: const Value(DateTime.tuesday),
            useDefault: const Value(false),
            customSize: const Value(null),
          ),
        );

    await weeklyPlanningRepository.restoreDefaultWeek();

    final weeklyCategoryRows =
        await db.select(db.weeklyPlanningCategorySettings).get();
    final days = await weeklyPlanningRepository.getAll();
    final summary = await weeklyPlanningRepository.watchWeekSummary().first;

    expect(weeklyCategoryRows, isEmpty);
    expect(days, hasLength(7));
    for (final day in days) {
      expect(day.useDefault, isTrue);
      expect(day.total, 7);
    }
    for (final day in summary) {
      expect(day.totalToys, 7);
    }
  });
}

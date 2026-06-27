import 'package:drift/drift.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';

class AgePresetService {
  final AppDatabase db;
  final SettingsRepository settingsRepository;
  static const _demoActiveRoundId = 'demo_active_round';

  const AgePresetService({
    required this.db,
    required this.settingsRepository,
  });

  Future<void> saveAgeRangeOnly(ChildAgeRange ageRange) {
    return settingsRepository.setChildAgeRange(ageRange);
  }

  Future<void> applyAgePreset(ChildAgeRange ageRange) async {
    await settingsRepository.setChildAgeRange(ageRange);
    await settingsRepository.setWeeklyPlanningEnabled(true);
    final preset = AgePresetCatalog.presetFor(ageRange);

    await db.transaction(() async {
      final categoryIdsByOfficialId = await _ensureOfficialCategories();
      await _preserveCustomWeekdays(categoryIdsByOfficialId.values.toSet());

      await _applyDefaultRoundPreset(
        _resolveOfficialQuotas(
          preset.quotasByCategoryId,
          categoryIdsByOfficialId,
        ),
      );
      await _reconcileLegacyFixedFivePlanningDays(
        categoryIdsByOfficialId.values.toSet(),
      );
      await _endActiveDemoRound();
      await _applyWeekendPresetIfAllowed(
        weekday: DateTime.saturday,
        preset: preset,
        categoryIdsByOfficialId: categoryIdsByOfficialId,
      );
      await _applyWeekendPresetIfAllowed(
        weekday: DateTime.sunday,
        preset: preset,
        categoryIdsByOfficialId: categoryIdsByOfficialId,
      );
    });
    await settingsRepository.setRoundSize(preset.total);
  }

  Future<void> _applyDefaultRoundPreset(
      Map<String, int> quotaByCategoryId) async {
    final categories = await db.select(db.categoryDefinitions).get();
    for (final category in categories) {
      final quota = quotaByCategoryId[category.id] ?? 0;
      await db.into(db.roundCategorySettings).insertOnConflictUpdate(
            RoundCategorySettingsCompanion.insert(
              categoryId: category.id,
              isIncluded: Value(quota > 0),
              quota: Value(quota),
            ),
          );
    }
  }

  Future<void> _applyWeekendPresetIfAllowed({
    required int weekday,
    required AgePreset preset,
    required Map<String, String> categoryIdsByOfficialId,
  }) async {
    final day = await _ensureWeeklyPlanningDay(weekday);
    if (!day.useDefault &&
        !await _isRecognizedAutomaticWeekendConfig(
          weekday: weekday,
          categoryIdsByOfficialId: categoryIdsByOfficialId,
        )) {
      return;
    }

    final quotasByCategoryId = _resolveOfficialQuotas(
      preset.quotasForWeekday(weekday),
      categoryIdsByOfficialId,
    );
    await _writeWeeklyDayPreset(
      weekday: weekday,
      quotasByCategoryId: quotasByCategoryId,
    );
  }

  Future<WeeklyPlanningSetting> _ensureWeeklyPlanningDay(int weekday) async {
    await db.into(db.weeklyPlanningSettings).insert(
          WeeklyPlanningSettingsCompanion.insert(
            weekday: Value(weekday),
            useDefault: const Value(true),
            customSize: const Value(null),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    return (db.select(db.weeklyPlanningSettings)
          ..where((day) => day.weekday.equals(weekday)))
        .getSingle();
  }

  Future<bool> _isRecognizedAutomaticWeekendConfig({
    required int weekday,
    required Map<String, String> categoryIdsByOfficialId,
  }) async {
    final categories = await (db.select(db.categoryDefinitions)
          ..where((category) => category.isActive.equals(true)))
        .get();
    final weeklyRows = await (db.select(db.weeklyPlanningCategorySettings)
          ..where((setting) => setting.weekday.equals(weekday)))
        .get();

    for (final ageRange in ChildAgeRange.values) {
      final preset = AgePresetCatalog.presetFor(ageRange);
      final expected = _resolveOfficialQuotas(
        preset.quotasForWeekday(weekday),
        categoryIdsByOfficialId,
      );
      if (_matchesWeeklyCategoryRows(
        categories: categories,
        weeklyRows: weeklyRows,
        expectedQuotasByCategoryId: expected,
      )) {
        return true;
      }
    }

    return false;
  }

  bool _matchesWeeklyCategoryRows({
    required List<CategoryDefinition> categories,
    required List<WeeklyPlanningCategorySetting> weeklyRows,
    required Map<String, int> expectedQuotasByCategoryId,
  }) {
    final rowsByCategoryId = <String, WeeklyPlanningCategorySetting>{
      for (final row in weeklyRows) row.categoryId: row,
    };

    for (final category in categories) {
      final expectedQuota = expectedQuotasByCategoryId[category.id] ?? 0;
      final expectedIncluded = expectedQuota > 0;
      final row = rowsByCategoryId[category.id];
      final actualQuota = row == null ? 0 : _safeQuota(row.quota);
      final actualIncluded = row?.isIncluded ?? false;

      if (actualIncluded != expectedIncluded) return false;
      if (actualQuota != expectedQuota) return false;
    }

    return true;
  }

  Future<void> _writeWeeklyDayPreset({
    required int weekday,
    required Map<String, int> quotasByCategoryId,
  }) async {
    await (db.update(db.weeklyPlanningSettings)
          ..where((day) => day.weekday.equals(weekday)))
        .write(
      const WeeklyPlanningSettingsCompanion(
        useDefault: Value(false),
        customSize: Value(null),
      ),
    );

    final categories = await db.select(db.categoryDefinitions).get();
    for (final category in categories) {
      final quota = quotasByCategoryId[category.id] ?? 0;
      await db.into(db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
            WeeklyPlanningCategorySettingsCompanion.insert(
              weekday: weekday,
              categoryId: category.id,
              isIncluded: Value(quota > 0),
              quota: Value(quota),
            ),
          );
    }
  }

  Map<String, int> _resolveOfficialQuotas(
    Map<String, int> quotasByOfficialId,
    Map<String, String> categoryIdsByOfficialId,
  ) {
    return <String, int>{
      for (final entry in quotasByOfficialId.entries)
        categoryIdsByOfficialId[entry.key]!: entry.value,
    };
  }

  Future<Map<String, String>> _ensureOfficialCategories() async {
    final categories = await db.select(db.categoryDefinitions).get();
    final byId = <String, CategoryDefinition>{
      for (final category in categories) category.id: category,
    };
    final result = <String, String>{};

    for (final official in AgePresetCatalog.officialCategories) {
      final existing = byId[official.id];
      if (existing == null) {
        result[official.id] = official.id;

        await db.into(db.categoryDefinitions).insert(
              CategoryDefinitionsCompanion.insert(
                id: official.id,
                name: official.name,
                description: const Value(null),
                examples: Value(official.examples),
                developmentAspect: Value(official.developmentAspect),
                sortOrder: Value(official.sortOrder),
                isDefault: const Value(true),
                isActive: const Value(true),
              ),
            );
        await db.into(db.categoryCounters).insert(
              CategoryCountersCompanion.insert(
                categoryId: official.id,
                nextNumber: const Value(1),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await db.into(db.roundCategorySettings).insert(
              RoundCategorySettingsCompanion.insert(
                categoryId: official.id,
                isIncluded: const Value(false),
                quota: const Value(0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        continue;
      }

      result[official.id] = existing.id;
      await (db.update(db.categoryDefinitions)
            ..where((category) => category.id.equals(existing.id)))
          .write(
        CategoryDefinitionsCompanion(
          name: Value(official.name),
          examples: _isBlank(existing.examples)
              ? Value(official.examples)
              : const Value.absent(),
          developmentAspect: _isBlank(existing.developmentAspect)
              ? Value(official.developmentAspect)
              : const Value.absent(),
          sortOrder: Value(official.sortOrder),
          isDefault: const Value(true),
          isActive: const Value(true),
        ),
      );
      await db.into(db.categoryCounters).insert(
            CategoryCountersCompanion.insert(
              categoryId: existing.id,
              nextNumber: const Value(1),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await db.into(db.roundCategorySettings).insert(
            RoundCategorySettingsCompanion.insert(
              categoryId: existing.id,
              isIncluded: const Value(false),
              quota: const Value(0),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    await _normalizeLegacyCategories();

    return result;
  }

  Future<void> _reconcileLegacyFixedFivePlanningDays(
    Set<String> officialCategoryIds,
  ) async {
    if (officialCategoryIds.length !=
        AgePresetCatalog.officialCategoryIds.length) {
      return;
    }

    final customDays = await (db.select(db.weeklyPlanningSettings)
          ..where((day) => day.useDefault.equals(false)))
        .get();

    for (final day in customDays) {
      if (!await _isLegacyFixedFiveWeeklyConfig(
        weekday: day.weekday,
        officialCategoryIds: officialCategoryIds,
      )) {
        continue;
      }

      await (db.update(db.weeklyPlanningSettings)
            ..where((row) => row.weekday.equals(day.weekday)))
          .write(
        const WeeklyPlanningSettingsCompanion(
          useDefault: Value(true),
          customSize: Value(null),
        ),
      );
    }
  }

  Future<bool> _isLegacyFixedFiveWeeklyConfig({
    required int weekday,
    required Set<String> officialCategoryIds,
  }) async {
    final rows = await (db.select(db.weeklyPlanningCategorySettings)
          ..where((row) => row.weekday.equals(weekday)))
        .get();
    if (rows.isEmpty) return false;

    var includedCount = 0;
    var includedTotal = 0;
    final seenOfficialIds = <String>{};
    for (final row in rows) {
      final safeQuota = _safeQuota(row.quota);
      if (!row.isIncluded || safeQuota <= 0) continue;
      if (!officialCategoryIds.contains(row.categoryId)) return false;
      if (safeQuota != 1) return false;
      seenOfficialIds.add(row.categoryId);
      includedCount++;
      includedTotal += safeQuota;
    }

    return includedCount == officialCategoryIds.length &&
        seenOfficialIds.length == officialCategoryIds.length &&
        includedTotal == officialCategoryIds.length;
  }

  Future<void> _endActiveDemoRound() async {
    await (db.update(db.rounds)
          ..where(
            (round) =>
                round.id.equals(_demoActiveRoundId) & round.endAt.isNull(),
          ))
        .write(
      RoundsCompanion(
        endAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> _preserveCustomWeekdays(Set<String> officialCategoryIds) async {
    if (officialCategoryIds.isEmpty) return;

    final customDays = await (db.select(db.weeklyPlanningSettings)
          ..where((day) => day.useDefault.equals(false)))
        .get();

    for (final day in customDays) {
      for (final categoryId in officialCategoryIds) {
        await db.into(db.weeklyPlanningCategorySettings).insert(
              WeeklyPlanningCategorySettingsCompanion.insert(
                weekday: day.weekday,
                categoryId: categoryId,
                isIncluded: const Value(false),
                quota: const Value(0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  int _safeQuota(int value) => value < 0 ? 0 : value;

  Future<void> _normalizeLegacyCategories() async {
    final categories = await db.select(db.categoryDefinitions).get();

    for (final category in categories) {
      final categoryId = category.id.trim();
      if (AgePresetCatalog.isOfficialCategoryId(categoryId)) continue;

      final targetCategoryId =
          AgePresetCatalog.officialCategoryIdForLegacyKey(category.id) ??
              AgePresetCatalog.officialCategoryIdForLegacyKey(category.name);
      if (targetCategoryId == null || targetCategoryId == category.id) {
        continue;
      }

      await (db.update(db.toys)
            ..where((toy) => toy.categoryId.equals(category.id)))
          .write(ToysCompanion(categoryId: Value(targetCategoryId)));
      await db.into(db.roundCategorySettings).insertOnConflictUpdate(
            RoundCategorySettingsCompanion.insert(
              categoryId: category.id,
              isIncluded: const Value(false),
              quota: const Value(0),
            ),
          );
      await (db.update(db.weeklyPlanningCategorySettings)
            ..where((row) => row.categoryId.equals(category.id)))
          .write(
        const WeeklyPlanningCategorySettingsCompanion(
          isIncluded: Value(false),
          quota: Value(0),
        ),
      );
      await (db.update(db.categoryDefinitions)
            ..where((row) => row.id.equals(category.id)))
          .write(
        CategoryDefinitionsCompanion(
          isDefault: const Value(false),
          isActive: const Value(false),
          sortOrder: Value(1000 + category.sortOrder),
        ),
      );
    }
  }
}

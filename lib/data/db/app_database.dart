import 'package:drift/drift.dart';
import 'package:rodizio_brinquedos_v3/data/db/connection/connection.dart';

part 'app_database.g.dart';

class Boxes extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().withDefault(const Constant(0))();
  TextColumn get local => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Toys extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().withDefault(const Constant('outros'))();
  TextColumn get name => text()();
  TextColumn get boxId => text().nullable().references(Boxes, #id)();
  TextColumn get locationText => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoryDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoryCounters extends Table {
  TextColumn get categoryId => text().references(CategoryDefinitions, #id)();
  IntColumn get nextNumber => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {categoryId};
}

class RoundCategorySettings extends Table {
  TextColumn get categoryId => text().references(CategoryDefinitions, #id)();
  BoolColumn get isIncluded => boolean().withDefault(const Constant(true))();
  IntColumn get quota => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {categoryId};
}

class RoundUiSettings extends Table {
  IntColumn get id => integer()();
  // Historical compatibility field. Active round size is now derived from
  // `round_category_settings.quota` for included active categories.
  IntColumn get perCategoryLimit => integer().withDefault(const Constant(12))();
  BoolColumn get hapticEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get darkModeEnabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ToyAutoNameCounters extends Table {
  IntColumn get boxIndex => integer()();
  IntColumn get nextNumber => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {boxIndex};
}

class LocationDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Rounds extends Table {
  TextColumn get id => text()();
  IntColumn get startAt => integer()();
  IntColumn get endAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RoundToys extends Table {
  TextColumn get roundId => text().references(Rounds, #id)();
  TextColumn get toyId => text().references(Toys, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {roundId, toyId};
}

class HistoryEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => text()();
  IntColumn get createdAt => integer()();
  TextColumn get payload => text()();
}

@DriftDatabase(
  tables: [
    Boxes,
    Toys,
    CategoryDefinitions,
    CategoryCounters,
    RoundCategorySettings,
    RoundUiSettings,
    ToyAutoNameCounters,
    LocationDefinitions,
    Rounds,
    RoundToys,
    HistoryEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(toys, toys.photoPath);
          }

          if (from < 3) {
            await m.addColumn(boxes, boxes.number);
            await m.addColumn(boxes, boxes.local);
            await m.addColumn(toys, toys.categoryId);
            await m.addColumn(toys, toys.locationText);

            await m.createTable(categoryDefinitions);
            await m.createTable(categoryCounters);
            await m.createTable(locationDefinitions);

            final oldBoxes = await (select(boxes)
                  ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
                .get();

            for (var i = 0; i < oldBoxes.length; i++) {
              final box = oldBoxes[i];
              final localValue =
                  box.name.trim().isEmpty ? 'Sem local' : box.name.trim();
              await (update(boxes)..where((b) => b.id.equals(box.id))).write(
                BoxesCompanion(
                  number: Value(i + 1),
                  local: Value(localValue),
                  name: Value('Caixa ${i + 1} - $localValue'),
                ),
              );
            }
          }

          if (from < 4) {
            await m.createTable(toyAutoNameCounters);
          }

          if (from < 5) {
            await m.createTable(roundCategorySettings);

            final categories = await select(categoryDefinitions).get();
            for (final c in categories) {
              await into(roundCategorySettings).insert(
                RoundCategorySettingsCompanion.insert(
                  categoryId: c.id,
                  isIncluded: const Value(true),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }

          if (from < 6) {
            await m.addColumn(
                roundCategorySettings, roundCategorySettings.quota);
            await m.createTable(roundUiSettings);
            await into(roundUiSettings).insert(
              RoundUiSettingsCompanion.insert(
                id: const Value(1),
                perCategoryLimit: const Value(12),
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }

          if (from < 7) {
            await m.addColumn(boxes, boxes.photoPath);
          }

          if (from < 8) {
            await m.addColumn(roundUiSettings, roundUiSettings.hapticEnabled);
            await m.addColumn(roundUiSettings, roundUiSettings.soundEnabled);
          }

          if (from < 9) {
            await m.database
                .customStatement('ALTER TABLE boxes ADD COLUMN notes TEXT');
          }

          if (from < 10) {
            await m.createTable(historyEvents);
          }

          if (from < 11) {
            await m.addColumn(
              roundUiSettings,
              roundUiSettings.darkModeEnabled,
            );
          }
        },
      );
}

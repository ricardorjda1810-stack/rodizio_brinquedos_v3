import 'package:drift/drift.dart';

class Boxes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Toys extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Caminho local da foto do brinquedo (1 foto por brinquedo)
  TextColumn get photoPath => text().nullable()();

  /// Caixa/Local atual do brinquedo (pode ser nulo)
  TextColumn get boxId => text().nullable().references(Boxes, #id)();

  IntColumn get createdAt => integer()();

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

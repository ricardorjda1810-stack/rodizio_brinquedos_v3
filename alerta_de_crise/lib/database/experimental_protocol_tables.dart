import 'package:drift/drift.dart';

class ExperimentalProtocolsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get phasesJson => text()();
  IntColumn get totalDurationSeconds => integer()();
  TextColumn get recommendedSensorsJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExperimentalProtocolSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get protocolId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get currentPhaseIndex => integer()();
  BoolColumn get completed => boolean()();
  TextColumn get generatedMarkersJson => text()();
  TextColumn get benchmarkId => text()();
  TextColumn get replayMetadataJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

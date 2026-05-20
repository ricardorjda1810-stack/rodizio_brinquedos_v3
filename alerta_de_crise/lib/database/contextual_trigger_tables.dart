import 'package:drift/drift.dart';

class ContextualEventsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get category => text()();
  TextColumn get label => text()();
  TextColumn get description => text()();
  TextColumn get intensity => text()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ContextualTriggerCorrelationsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get category => text()();
  IntColumn get occurrenceCount => integer()();
  RealColumn get escalationCorrelation => real()();
  RealColumn get recoveryImpact => real()();
  RealColumn get confidence => real()();
  DateTimeColumn get lastOccurrence => dateTime().nullable()();
  TextColumn get associatedMarkersJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

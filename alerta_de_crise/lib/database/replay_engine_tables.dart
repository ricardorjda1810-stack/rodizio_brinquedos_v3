import 'package:drift/drift.dart';

class ReplayScenariosTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get generatedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get sampleCount => integer()();
  TextColumn get scenarioType => text()();
  TextColumn get expectedEscalationLevel => text()();
  TextColumn get contextualFactors => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReplayValidationResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get scenarioId => text()();
  DateTimeColumn get generatedAt => dateTime()();
  RealColumn get replayConsistency => real()();
  RealColumn get timelineConsistency => real()();
  RealColumn get forecastConsistency => real()();
  RealColumn get escalationDetectionScore => real()();
  RealColumn get recoveryModelingScore => real()();
  TextColumn get findings => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

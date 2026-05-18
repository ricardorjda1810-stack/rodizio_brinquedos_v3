import 'package:drift/drift.dart';

class RecordedExperimentalSessionsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get protocolId => text().nullable()();
  IntColumn get totalSamples => integer()();
  IntColumn get totalMarkers => integer()();
  IntColumn get totalForecasts => integer()();
  IntColumn get totalInsights => integer()();
  IntColumn get totalContextEvents => integer()();
  IntColumn get totalSubjectiveEntries => integer()();
  RealColumn get averageHeartRate => real()();
  RealColumn get averageHrv => real()();
  RealColumn get averageConfidence => real()();
  IntColumn get escalationEvents => integer()();
  IntColumn get recoveryEvents => integer()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionSnapshotsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get heartRate => real()();
  RealColumn get hrv => real()();
  RealColumn get confidence => real()();
  TextColumn get escalationLevel => text()();
  RealColumn get forecastProbability => real()();
  TextColumn get recoveryState => text()();
  RealColumn get resilience => real()();
  TextColumn get contextualState => text()();
  TextColumn get multimodalConsensus => text()();
  TextColumn get rawJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

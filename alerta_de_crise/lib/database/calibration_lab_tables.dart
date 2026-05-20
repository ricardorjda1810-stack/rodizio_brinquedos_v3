import 'package:drift/drift.dart';

class CalibrationProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  RealColumn get heartRateSensitivity => real()();
  RealColumn get hrvSuppressionSensitivity => real()();
  RealColumn get recoverySensitivity => real()();
  RealColumn get forecastSensitivity => real()();
  RealColumn get confidenceWeight => real()();
  RealColumn get fusionWeight => real()();
  RealColumn get escalationThreshold => real()();
  RealColumn get recoveryThreshold => real()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CalibrationBenchmarkResultsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get profileId => text()();
  TextColumn get profileName => text()();
  TextColumn get sessionId => text()();
  RealColumn get forecastConsistency => real()();
  RealColumn get recoveryConsistency => real()();
  RealColumn get falseEscalationRate => real()();
  RealColumn get multimodalAgreement => real()();
  RealColumn get confidenceConsistency => real()();
  RealColumn get benchmarkScore => real()();
  IntColumn get rankingPosition => integer()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

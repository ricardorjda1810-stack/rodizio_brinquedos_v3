import 'package:drift/drift.dart';

class ReplayBenchmarkResultsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get sessionId => text()();
  TextColumn get replayScenario => text()();
  RealColumn get forecastConsistency => real()();
  RealColumn get recoveryConsistency => real()();
  RealColumn get escalationDetectionRate => real()();
  RealColumn get falseEscalationRate => real()();
  RealColumn get multimodalAgreement => real()();
  RealColumn get confidenceConsistency => real()();
  RealColumn get benchmarkScore => real()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class RealtimePipelineSnapshotsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  IntColumn get bufferSize => integer()();
  RealColumn get rollingHeartRate => real()();
  RealColumn get rollingHrv => real()();
  RealColumn get rollingConfidence => real()();
  RealColumn get rollingEscalationDensity => real()();
  RealColumn get latestEscalationProbability => real()();
  TextColumn get streamingState => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

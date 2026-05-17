import 'package:drift/drift.dart';

class AutonomicRecoveryProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get timelineId => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get windowLabel => text()();
  IntColumn get windowSeconds => integer()();
  RealColumn get recoveryRate => real()();
  RealColumn get hrvRecoverySlope => real()();
  RealColumn get heartRateNormalization => real()();
  IntColumn get baselineReturnSeconds => integer().nullable()();
  IntColumn get resilienceScore => integer()();
  IntColumn get fatigueScore => integer()();
  RealColumn get stressCarryover => real()();
  TextColumn get resilienceLevel => text()();

  @override
  Set<Column> get primaryKey => {id};
}

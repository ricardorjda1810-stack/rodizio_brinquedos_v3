import 'package:drift/drift.dart';

class ResearchDashboardSnapshotsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  RealColumn get averageHeartRate => real().nullable()();
  RealColumn get averageHrv => real().nullable()();
  RealColumn get averageConfidence => real()();
  IntColumn get escalationCount => integer()();
  IntColumn get interventionCount => integer()();
  RealColumn get recoveryEfficiency => real()();
  IntColumn get resilienceScore => integer()();
  IntColumn get fatigueScore => integer()();
  RealColumn get activationDensity => real()();
  RealColumn get baselineStability => real()();
  RealColumn get stressCarryover => real()();
  BoolColumn get improvingTrend => boolean()();
  BoolColumn get worseningTrend => boolean()();
  BoolColumn get recoveryTrend => boolean()();
  BoolColumn get confidenceTrend => boolean()();
  BoolColumn get circadianStability => boolean()();
  RealColumn get autonomicLoad => real()();

  @override
  Set<Column> get primaryKey => {id};
}

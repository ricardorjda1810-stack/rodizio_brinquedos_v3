import 'package:drift/drift.dart';

class CohortAnalysisResultsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  IntColumn get comparedSessions => integer()();
  RealColumn get averageRecoveryEfficiency => real()();
  RealColumn get averageEscalationProbability => real()();
  RealColumn get averageResilience => real()();
  RealColumn get stabilityScore => real()();
  RealColumn get variabilityScore => real()();
  RealColumn get contextualConsistency => real()();
  RealColumn get longitudinalConfidence => real()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PhysiologicalEvolutionProfilesTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get baselineTrend => text()();
  TextColumn get recoveryTrend => text()();
  TextColumn get resilienceTrend => text()();
  TextColumn get escalationTrend => text()();
  TextColumn get autonomicLoadTrend => text()();
  TextColumn get circadianStabilityTrend => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

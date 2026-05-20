import 'package:drift/drift.dart';

class InterventionLearningProfilesTable extends Table {
  TextColumn get interventionType => text()();
  RealColumn get successRate => real()();
  IntColumn get averageRecoveryTimeSeconds => integer()();
  RealColumn get averageRecoveryImprovement => real()();
  TextColumn get contextualPerformanceJson => text()();
  TextColumn get circadianPerformanceJson => text()();
  RealColumn get confidence => real()();
  IntColumn get usageCount => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {interventionType};
}

class ContextualInterventionRecommendationsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get interventionType => text()();
  RealColumn get recommendationScore => real()();
  RealColumn get expectedRecoveryBenefit => real()();
  RealColumn get confidence => real()();
  TextColumn get contextualFactorsJson => text()();
  TextColumn get physiologicalFactorsJson => text()();
  TextColumn get recoveryFactorsJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class EscalationForecastsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  IntColumn get forecastWindowSeconds => integer()();
  TextColumn get forecastWindowLabel => text()();
  RealColumn get escalationProbability => real()();
  IntColumn get forecastConfidence => integer()();
  TextColumn get forecastConfidenceLevel => text()();
  TextColumn get escalationRiskLevel => text()();
  TextColumn get contributingFactorsJson => text()();
  RealColumn get recoveryProtection => real()();
  RealColumn get autonomicLoad => real()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

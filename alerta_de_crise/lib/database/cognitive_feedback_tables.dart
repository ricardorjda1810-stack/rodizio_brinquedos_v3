import 'package:drift/drift.dart';

class SubjectiveFeedbackEntriesTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  DateTimeColumn get perceivedTimestamp => dateTime()();
  IntColumn get perceivedStress => integer()();
  IntColumn get perceivedFatigue => integer()();
  IntColumn get perceivedControl => integer()();
  IntColumn get perceivedRecovery => integer()();
  IntColumn get emotionalIntensity => integer()();
  TextColumn get notes => text()();
  TextColumn get contextualFactors => text()();
  RealColumn get physiologicalCorrelation => real()();
  RealColumn get confidence => real()();
  TextColumn get relatedMarkers => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

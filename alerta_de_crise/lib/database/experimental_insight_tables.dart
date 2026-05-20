import 'package:drift/drift.dart';

class ExperimentalInsightsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  RealColumn get confidence => real()();
  TextColumn get insightType => text()();
  TextColumn get contributingFactors => text()();
  TextColumn get relatedMarkers => text()();
  TextColumn get relatedForecasts => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

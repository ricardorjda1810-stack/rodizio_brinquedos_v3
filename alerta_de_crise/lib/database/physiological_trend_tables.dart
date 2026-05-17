import 'package:drift/drift.dart';

class PhysiologicalTrendsTable extends Table {
  TextColumn get id => text()();
  TextColumn get timelineId => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get windowLabel => text()();
  IntColumn get windowSeconds => integer()();
  RealColumn get averageHeartRate => real().nullable()();
  RealColumn get averageHrv => real().nullable()();
  RealColumn get hrvSlope => real()();
  RealColumn get heartRateSlope => real()();
  RealColumn get activationDensity => real()();
  IntColumn get escalationScore => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

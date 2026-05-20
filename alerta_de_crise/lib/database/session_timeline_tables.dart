import 'package:drift/drift.dart';

class SessionTimelineTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalSamples => integer()();
  IntColumn get totalEvents => integer()();
  RealColumn get averageHeartRate => real().nullable()();
  RealColumn get averageHrv => real().nullable()();
  RealColumn get maxHeartRate => real().nullable()();
  RealColumn get minHrv => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PhysiologicalEventMarkersTable extends Table {
  TextColumn get id => text()();
  TextColumn get timelineId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get severity => text()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class InterventionHistoryTable extends Table {
  TextColumn get id => text()();
  TextColumn get protocolId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get completed => boolean()();
  BoolColumn get userReportedImprovement => boolean()();
  TextColumn get finalResponse => text()();
  IntColumn get preScore => integer().nullable()();
  IntColumn get postScore => integer().nullable()();
  IntColumn get scoreDelta => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

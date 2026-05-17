import 'package:drift/drift.dart';

class ResearchConsentTable extends Table {
  TextColumn get id => text()();
  BoolColumn get accepted => boolean()();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  TextColumn get version => text()();
  BoolColumn get allowsPhysiologicalCollection => boolean()();
  BoolColumn get allowsResearchExport => boolean()();
  BoolColumn get allowsReplayAnalysis => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

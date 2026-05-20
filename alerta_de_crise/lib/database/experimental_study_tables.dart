import 'package:drift/drift.dart';

class ExperimentalStudiesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get protocolId => text()();
  IntColumn get totalSessions => integer()();
  IntColumn get totalParticipants => integer()();
  IntColumn get targetDurationSeconds => integer()();
  TextColumn get studyTagsJson => text()();
  TextColumn get enabledSensorsJson => text()();
  BoolColumn get active => boolean()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExperimentalStudySessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get studyId => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get success => boolean()();
  BoolColumn get replayGenerated => boolean()();
  BoolColumn get benchmarkGenerated => boolean()();
  BoolColumn get subjectiveFeedbackIncluded => boolean()();
  RealColumn get multimodalConsensusScore => real()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

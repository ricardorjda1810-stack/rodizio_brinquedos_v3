import 'package:drift/drift.dart';

class AdaptiveBaselineStateTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get totalSamples => integer()();
  RealColumn get restingHeartRate => real()();
  RealColumn get hrvRmssd => real()();
  RealColumn get respiratoryRate => real()();
  RealColumn get movementIntensity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class CircadianProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get baselineId => text()();
  TextColumn get windowLabel => text()();
  IntColumn get startHour => integer()();
  IntColumn get endHour => integer()();
  RealColumn get averageHeartRate => real()();
  RealColumn get averageHrv => real().nullable()();
  RealColumn get averageRespiratoryRate => real().nullable()();
  IntColumn get sampleCount => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

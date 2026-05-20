import 'package:drift/drift.dart';

class BaselineProfilesTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  RealColumn get restingHeartRate => real()();
  RealColumn get hrvRmssd => real()();
  RealColumn get respiratoryRate => real()();
  RealColumn get movementIntensity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

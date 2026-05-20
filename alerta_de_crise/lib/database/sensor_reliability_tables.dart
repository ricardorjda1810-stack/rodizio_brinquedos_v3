import 'package:drift/drift.dart';

class SensorReliabilityProfilesTable extends Table {
  TextColumn get sensorType => text()();
  IntColumn get sampleCount => integer()();
  RealColumn get averageConfidence => real()();
  RealColumn get artifactRate => real()();
  RealColumn get missingDataRate => real()();
  RealColumn get timingDriftMs => real()();
  RealColumn get agreementWithReference => real()();
  RealColumn get reliabilityScore => real()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {sensorType};
}

class SensorComparisonResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get primarySensor => text()();
  TextColumn get referenceSensor => text()();
  RealColumn get heartRateAgreement => real()();
  RealColumn get hrvAgreement => real()();
  RealColumn get timingAgreement => real()();
  IntColumn get divergenceCount => integer()();
  RealColumn get averageDriftMs => real()();
  RealColumn get confidenceDelta => real()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

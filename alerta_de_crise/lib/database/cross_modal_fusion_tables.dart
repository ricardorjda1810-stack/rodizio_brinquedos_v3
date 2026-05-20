import 'package:drift/drift.dart';

class IntegratedConsensusSnapshotsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();
  RealColumn get integratedStressLoad => real()();
  RealColumn get integratedRecoveryState => real()();
  RealColumn get integratedResilience => real()();
  RealColumn get multimodalConfidence => real()();
  TextColumn get multimodalConfidenceLevel => text()();
  RealColumn get signalAgreement => real()();
  TextColumn get contributingSignalsJson => text()();
  TextColumn get disagreementFactorsJson => text()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

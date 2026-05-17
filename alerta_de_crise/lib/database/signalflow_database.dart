import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'baseline_tables.dart';
import 'consent_tables.dart';
import 'crisis_tables.dart';
import 'intervention_tables.dart';

part 'signalflow_database.g.dart';

@DriftDatabase(
  tables: [
    BaselineProfilesTable,
    CrisisRiskEventsTable,
    InterventionHistoryTable,
    ResearchConsentTable,
  ],
)
final class SignalFlowDatabase extends _$SignalFlowDatabase {
  SignalFlowDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'signalflow'));

  factory SignalFlowDatabase.memory() {
    return SignalFlowDatabase(NativeDatabase.memory());
  }

  static final SignalFlowDatabase instance = SignalFlowDatabase();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {},
    );
  }

  Future<void> clearAllSignalFlowTables() async {
    await batch((batch) {
      batch.deleteAll(baselineProfilesTable);
      batch.deleteAll(crisisRiskEventsTable);
      batch.deleteAll(interventionHistoryTable);
      batch.deleteAll(researchConsentTable);
    });
  }
}

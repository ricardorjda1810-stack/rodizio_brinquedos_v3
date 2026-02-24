import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'rodizio_brinquedos',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        // ignore: avoid_print
        print(
          'Drift WASM fallback: ${result.chosenImplementation}; '
          'missing: ${result.missingFeatures}',
        );
      }

      return DatabaseConnection(result.resolvedExecutor);
    }),
  );
}

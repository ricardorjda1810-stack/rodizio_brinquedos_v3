import 'package:drift/drift.dart';

class ExperimentalPipelineRunsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get pipelineType => text()();
  IntColumn get processedSamples => integer()();
  IntColumn get generatedForecasts => integer()();
  IntColumn get generatedInsights => integer()();
  IntColumn get generatedMarkers => integer()();
  IntColumn get executionDurationMs => integer()();
  BoolColumn get success => boolean()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class OrchestratorWorkflowsTable extends Table {
  TextColumn get workflowId => text()();
  TextColumn get title => text()();
  TextColumn get enabledPipelines => text()();
  IntColumn get executionFrequencySeconds => integer()();
  DateTimeColumn get lastExecution => dateTime().nullable()();
  IntColumn get totalExecutions => integer()();
  IntColumn get averageExecutionTimeMs => integer()();
  TextColumn get safetyCopy => text()();

  @override
  Set<Column> get primaryKey => {workflowId};
}

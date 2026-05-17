import 'package:drift/drift.dart';

class CrisisRiskEventsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get score => integer()();
  TextColumn get level => text()();
  TextColumn get reasonCodesJson => text()();
  TextColumn get recommendedAction => text()();
  TextColumn get cognitiveResponse => text()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}

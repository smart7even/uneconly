import 'package:drift/drift.dart';

@DataClassName('ScheduleRuleDatabaseEntity')
class ScheduleRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer()();
  TextColumn get lesson => text()();
  TextColumn get lessonType => text().nullable()();
  TextColumn get professor => text()();
}

import 'package:drift/drift.dart';

@DataClassName('LessonDatabaseEntity')
class Lessons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  TextColumn get professor => text().nullable()();
  TextColumn get location => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get groupId => integer().nullable()();
}

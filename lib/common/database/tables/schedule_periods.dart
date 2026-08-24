import 'package:drift/drift.dart';

@DataClassName('SchedulePeriodDatabaseEntity')
class SchedulePeriods extends Table {
  TextColumn get scope => text()();
  IntColumn get week => integer()();
  IntColumn get academicYearStart => integer()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {scope, week};
}

import 'package:drift/drift.dart';

const currentScheduleCacheVersion = 1;

@DataClassName('SchedulePeriodDatabaseEntity')
class SchedulePeriods extends Table {
  TextColumn get scope => text()();
  IntColumn get week => integer()();
  IntColumn get cacheVersion => integer().withDefault(const Constant(0))();
  IntColumn get academicYearStart => integer()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  BoolColumn get hasScheduleDays =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {scope, week};
}

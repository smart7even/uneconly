import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uneconly/common/database/tables/lessons.dart';
import 'package:uneconly/common/database/tables/schedule_periods.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Lessons, SchedulePeriods])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  MyDatabase.forTesting(super.executor);

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1 to
          // version 2
          await m.addColumn(lessons, lessons.groupId);
        }

        if (from < 3) {
          // we added the dueDate property in the change from version 2 to
          // version 3
          await m.addColumn(lessons, lessons.lessonType);
        }

        if (from < 4) {
          // we added the professorId property in the change from version 3 to
          // version 4
          await m.addColumn(lessons, lessons.professorId);
        }

        if (from < 5) {
          // we added the group property in the change from version 4 to
          // version 5
          await m.addColumn(lessons, lessons.group);
        }

        if (from < 6) {
          await m.addColumn(lessons, lessons.roomUrl);
        }

        if (from < 7) {
          await m.createTable(schedulePeriods);
        }

        if (from >= 7 && from < 8) {
          // Existing schedule rows may have been produced by the old
          // fixed-seven-day replacement logic. Keep them physically for a
          // safe migration, but mark them as legacy through the column's
          // default value so they are not trusted by the reader.
          await m.addColumn(schedulePeriods, schedulePeriods.cacheVersion);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

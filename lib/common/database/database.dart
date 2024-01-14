import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uneconly/common/database/tables/lessons.dart';
import 'package:uneconly/common/database/tables/schedule_rule.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Lessons, ScheduleRules])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the groupId property in the change from version 1 to
          // version 2
          await m.addColumn(lessons, lessons.groupId);
        }

        if (from < 3) {
          // we added the lessonType property in the change from version 2 to
          // version 3
          await m.addColumn(lessons, lessons.lessonType);
        }

        if (from < 4) {
          // we added the ScheduleRules table in the change from version 3 to
          // version 4
          await m.createTable(scheduleRules);
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

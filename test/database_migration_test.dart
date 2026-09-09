import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:uneconly/common/database/database.dart';

void main() {
  test('schema 8 empty periods migrate to the safe unpublished state', () async {
    final directory = await Directory.systemTemp.createTemp(
      'uneconly-schema-8-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/db.sqlite');

    final legacy = sqlite.sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE schedule_periods (
        scope TEXT NOT NULL,
        week INTEGER NOT NULL,
        cache_version INTEGER NOT NULL DEFAULT 0,
        academic_year_start INTEGER NOT NULL,
        period_start INTEGER NOT NULL,
        period_end INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (scope, week)
      );
    ''');
    legacy.execute('''
      INSERT INTO schedule_periods (
        scope,
        week,
        cache_version,
        academic_year_start,
        period_start,
        period_end,
        updated_at
      ) VALUES (
        'group:2601',
        3,
        1,
        2026,
        '2026-09-14T00:00:00.000',
        '2026-09-20T00:00:00.000',
        '2026-09-14T00:00:00.000'
      );
    ''');
    legacy.execute('PRAGMA user_version = 8;');
    legacy.close();

    final database = MyDatabase.forTesting(NativeDatabase(file));
    addTearDown(database.close);

    final period = await database.select(database.schedulePeriods).getSingle();
    final columns = await database
        .customSelect('PRAGMA table_info(schedule_periods)')
        .get();

    expect(database.schemaVersion, 9);
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('has_schedule_days'),
    );
    expect(period.hasScheduleDays, isFalse);
  });
}

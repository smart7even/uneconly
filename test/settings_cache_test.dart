import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

void main() {
  late MyDatabase database;
  late SettingsLocalDataProvider settings;
  late ScheduleLocalDataProvider schedules;

  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = MyDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsLocalDataProvider(
      prefs: await SharedPreferences.getInstance(),
      database: database,
    );
    schedules = ScheduleLocalDataProvider(database);
  });

  tearDown(() => database.close());

  test('an explicitly empty schedule still counts as cached data', () async {
    await schedules.saveSchedule(
      Schedule(
        week: 3,
        info: info,
        daySchedules: const [],
        academicYearStart: 2026,
        periodStart: DateTime(2026, 9, 14),
        periodEnd: DateTime(2026, 9, 20),
      ),
    );

    expect(await settings.isAppCacheEmpty(), isFalse);
  });

  test('clear cache removes both period metadata and lesson rows', () async {
    await schedules.saveSchedule(
      Schedule(
        week: 3,
        info: info,
        daySchedules: const [],
        academicYearStart: 2026,
        periodStart: DateTime(2026, 9, 14),
        periodEnd: DateTime(2026, 9, 20),
      ),
    );

    await settings.clearAppCache();

    expect(await settings.isAppCacheEmpty(), isTrue);
    expect(await database.select(database.schedulePeriods).get(), isEmpty);
    expect(await database.select(database.lessons).get(), isEmpty);
  });
}

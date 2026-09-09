import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_calendar_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_context.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

void main() {
  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
  );

  Schedule schedule(int week, DateTime start) => Schedule(
        week: week,
        info: info,
        daySchedules: const [],
        academicYearStart: 2026,
        periodStart: start,
        periodEnd: start.add(const Duration(days: 6)),
      );

  late _ControllableNetwork network;
  late _RecordingLocal local;
  late ScheduleRepository repository;

  setUp(() {
    network = _ControllableNetwork();
    local = _RecordingLocal();
    repository = ScheduleRepository(
      networkDataProvider: network,
      localDataProvider: local,
      calendarDataProvider: _UnusedCalendar(),
      settingsLocalDataProvider: _SettingsWithoutCalendarSync(),
    );
  });

  test('an older same-week response cannot overwrite a newer completed one',
      () async {
    final older = repository.fetch(info: info, week: 2);
    final newer = repository.fetch(info: info, week: 2);
    await network.waitForRequests(2);

    network.complete(1, schedule(2, DateTime(2026, 9, 7)));
    await newer;
    network.complete(0, schedule(2, DateTime(2026, 9, 8)));
    await older;

    expect(local.saved, hasLength(1));
    expect(local.saved.single.periodStart, DateTime(2026, 9, 7));
  });

  test('a hanging or failed newer request does not discard an older success',
      () async {
    final older = repository.fetch(info: info, week: 2);
    final newer = repository.fetch(info: info, week: 2);
    await network.waitForRequests(2);

    network.fail(1, StateError('offline'));
    await expectLater(newer, throwsStateError);
    network.complete(0, schedule(2, DateTime(2026, 9, 7)));
    await older;

    expect(local.saved, hasLength(1));
    expect(local.saved.single.week, 2);
  });

  test('requests for different weeks keep independent cache revisions',
      () async {
    final week1 = repository.fetch(info: info, week: 1);
    final week2 = repository.fetch(info: info, week: 2);
    await network.waitForRequests(2);

    network.complete(1, schedule(2, DateTime(2026, 9, 7)));
    network.complete(0, schedule(1, DateTime(2026, 9, 1)));
    await Future.wait([week1, week2]);

    expect(local.saved.map((schedule) => schedule.week), containsAll([1, 2]));
  });

  test('cache revision key ignores display-name changes for the same group',
      () async {
    const incompleteInfo = ScheduleInfo.group(
      shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: null),
    );
    final older = repository.fetch(info: incompleteInfo, week: 2);
    final newer = repository.fetch(info: info, week: 2);
    await network.waitForRequests(2);

    network.complete(1, schedule(2, DateTime(2026, 9, 7)));
    await newer;
    network.complete(0, schedule(2, DateTime(2026, 9, 8)));
    await older;

    expect(local.saved, hasLength(1));
    expect(local.saved.single.periodStart, DateTime(2026, 9, 7));
  });

  test('serialized writes leave the newest same-week response in cache',
      () async {
    local.blockFirstSave = true;
    final older = repository.fetch(info: info, week: 2);
    await network.waitForRequests(1);
    network.complete(0, schedule(2, DateTime(2026, 9, 8)));
    await local.firstSaveStarted.future;

    final newer = repository.fetch(info: info, week: 2);
    await network.waitForRequests(2);
    network.complete(1, schedule(2, DateTime(2026, 9, 7)));

    local.releaseFirstSave.complete();
    await Future.wait([older, newer]);

    expect(local.saved, hasLength(2));
    expect(local.saved.last.periodStart, DateTime(2026, 9, 7));
  });
}

class _ControllableNetwork implements IScheduleNetworkDataProvider {
  final requests = <Completer<Schedule>>[];

  @override
  Future<Schedule> fetch({required ScheduleInfo info, int? week}) {
    final completer = Completer<Schedule>();
    requests.add(completer);
    return completer.future;
  }

  Future<void> waitForRequests(int count) async {
    for (var attempt = 0; attempt < 100 && requests.length < count; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(requests, hasLength(count));
  }

  void complete(int index, Schedule schedule) =>
      requests[index].complete(schedule);

  void fail(int index, Object error) => requests[index].completeError(error);

  @override
  Future<AppConfig> fetchAppConfig() => throw UnimplementedError();

  @override
  Future<ScheduleContext> fetchContext() => throw UnimplementedError();
}

class _RecordingLocal implements IScheduleLocalDataProvider {
  final saved = <Schedule>[];
  bool blockFirstSave = false;
  final firstSaveStarted = Completer<void>();
  final releaseFirstSave = Completer<void>();

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    if (blockFirstSave && !firstSaveStarted.isCompleted) {
      firstSaveStarted.complete();
      await releaseFirstSave.future;
    }
    saved.add(schedule);
  }

  @override
  Future<ScheduleCacheEntry?> getClosestSchedule(
    DateTime date,
    ScheduleInfo info,
  ) async =>
      null;

  @override
  Future<ScheduleCacheEntry?> getSchedule(
    int week,
    ScheduleInfo info,
    int? academicYearStart,
  ) async =>
      null;
}

class _UnusedCalendar implements IScheduleCalendarDataProvider {
  @override
  Future<void> saveSchedule(Schedule schedule) => throw UnimplementedError();
}

class _SettingsWithoutCalendarSync implements ISettingsLocalDataProvider {
  @override
  Future<Group?> getGroup() async => null;

  @override
  Future<bool> isSystemCalendarSyncingEnabled() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

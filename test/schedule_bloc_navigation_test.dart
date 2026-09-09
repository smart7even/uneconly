import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';

void main() {
  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
  );

  Schedule schedule(int week) => Schedule(
        week: week,
        info: info,
        daySchedules: const [],
        academicYearStart: 2026,
        periodStart: week == 1 ? DateTime(2026, 9, 1) : DateTime(2026, 9, 7),
        periodEnd: week == 1 ? DateTime(2026, 9, 6) : DateTime(2026, 9, 13),
      );

  test('a superseded week fetch cannot publish stale selected state', () async {
    final repository = _ControllableScheduleRepository();
    final initialSchedule = schedule(1);
    final bloc = ScheduleBLoC(
      repository: repository,
      groupRepository: _UnusedGroupRepository(),
      initialState: ScheduleState.successful(
        currentWeek: 1,
        selectedWeek: 1,
        data: {
          1: ScheduleDetails(schedule: initialSchedule, isLocal: false),
        },
        scheduleInfo: info,
      ),
    );
    addTearDown(bloc.close);

    final states = <ScheduleState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const ScheduleEvent.fetch(
      week: 2,
      info: info,
      academicYearStart: 2026,
    ));
    await bloc.stream.firstWhere(
      (state) => state.selectedWeek == 2 && state.isProcessing,
    );

    final stateCountBeforeLatestIntent = states.length;
    bloc.add(const ScheduleEvent.fetch(
      week: 1,
      info: info,
      academicYearStart: 2026,
    ));
    await bloc.stream.firstWhere(
      (state) => state.selectedWeek == 1 && state.isProcessing,
    );

    final latestFetchCompleted = bloc.stream.firstWhere(
      (state) => state.selectedWeek == 1 && !state.isProcessing,
    );
    repository.complete(2, schedule(2));
    repository.complete(1, schedule(1));
    await latestFetchCompleted;

    final statesAfterLatestIntent = states.skip(stateCountBeforeLatestIntent);
    expect(
      statesAfterLatestIntent.any(
        (state) => state.selectedWeek == 2 && !state.isProcessing,
      ),
      isFalse,
    );
  });

  test('week 2 cache is shown while week 1 network fetch never completes',
      () async {
    final cachedAt = DateTime(2026, 8, 31, 2, 30);
    final repository = _ControllableScheduleRepository(
      cached: {
        1: ScheduleCacheEntry(schedule: schedule(1), updatedAt: cachedAt),
        2: ScheduleCacheEntry(schedule: schedule(2), updatedAt: cachedAt),
      },
    );
    final bloc = ScheduleBLoC(
      repository: repository,
      groupRepository: _UnusedGroupRepository(),
    );
    addTearDown(bloc.close);

    bloc.add(const ScheduleEvent.fetch(
      week: 1,
      info: info,
      academicYearStart: 2026,
      setAsCurrent: true,
    ));
    await bloc.stream.firstWhere(
      (state) =>
          state.selectedWeek == 1 &&
          state.data[1]?.isLocal == true &&
          state.isProcessing,
    );

    bloc.add(const ScheduleEvent.fetch(
      week: 2,
      info: info,
      academicYearStart: 2026,
    ));
    final week2FromCache = await bloc.stream.firstWhere(
      (state) =>
          state.selectedWeek == 2 &&
          state.data[2]?.isLocal == true &&
          state.isProcessing,
    );

    expect(week2FromCache.currentWeek, 1);
    expect(week2FromCache.data[2]!.schedule.periodStart, DateTime(2026, 9, 7));
    expect(week2FromCache.data[2]!.updatedAt, cachedAt);
    expect(repository.hasPendingFetch(1), isTrue);
    expect(repository.hasPendingFetch(2), isTrue);

    repository.complete(1, schedule(1));
    repository.complete(2, schedule(2));
  });

  test('a superseded request still finishes and populates its cache', () async {
    final repository = _ControllableScheduleRepository();
    final bloc = ScheduleBLoC(
      repository: repository,
      groupRepository: _UnusedGroupRepository(),
      initialState: ScheduleState.successful(
        currentWeek: 1,
        selectedWeek: 1,
        data: {
          1: ScheduleDetails(schedule: schedule(1), isLocal: true),
        },
        scheduleInfo: info,
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const ScheduleEvent.fetch(
      week: 1,
      info: info,
      academicYearStart: 2026,
    ));
    await bloc.stream.firstWhere(
      (state) => state.selectedWeek == 1 && state.isProcessing,
    );
    await _waitUntil(() => repository.hasPendingFetch(1));

    bloc.add(const ScheduleEvent.fetch(
      week: 2,
      info: info,
      academicYearStart: 2026,
    ));
    await bloc.stream.firstWhere(
      (state) => state.selectedWeek == 2 && state.isProcessing,
    );
    await _waitUntil(() => repository.hasPendingFetch(2));

    repository.complete(1, schedule(1));
    await _waitUntil(() => repository.refreshedCache.containsKey(1));

    expect(repository.refreshedCache[1]!.periodStart, DateTime(2026, 9, 1));
    expect(bloc.state.selectedWeek, 2);
    expect(bloc.state.isProcessing, isTrue);

    repository.complete(2, schedule(2));
    await bloc.stream.firstWhere(
      (state) => state.selectedWeek == 2 && !state.isProcessing,
    );
  });

  test('changing an existing page from a group to a professor fetches data',
      () async {
    const professorInfo = ScheduleInfo.professor(
      shortProfessorInfo: ShortProfessorInfo(
        professorId: 77,
        professorName: 'Иванов И. И.',
      ),
    );
    final repository = _ControllableScheduleRepository();
    final bloc = ScheduleBLoC(
      repository: repository,
      groupRepository: _UnusedGroupRepository(),
      initialState: ScheduleState.successful(
        currentWeek: 2,
        selectedWeek: 2,
        data: {
          2: ScheduleDetails(schedule: schedule(2), isLocal: false),
        },
        scheduleInfo: info,
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const ScheduleEvent.changeGroup(
      week: 2,
      info: professorInfo,
      academicYearStart: 2026,
    ));
    await _waitUntil(() => repository.hasPendingFetch(2));

    final professorSchedule = Schedule(
      week: 2,
      info: professorInfo,
      daySchedules: const [],
      academicYearStart: 2026,
      periodStart: DateTime(2026, 9, 7),
      periodEnd: DateTime(2026, 9, 13),
    );
    final loaded = bloc.stream.firstWhere(
      (state) =>
          state.scheduleInfo == professorInfo &&
          state.data[2]?.schedule.info == professorInfo &&
          !state.isProcessing,
    );
    repository.complete(2, professorSchedule);

    expect((await loaded).scheduleInfo, professorInfo);
    expect(repository.requestedInfos, contains(professorInfo));
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition was not met before timeout');
}

class _ControllableScheduleRepository implements IScheduleRepository {
  _ControllableScheduleRepository({
    this.cached = const {},
  });

  final _completers = <int, Completer<Schedule>>{};
  final Map<int, ScheduleCacheEntry> cached;
  final Map<int, Schedule> refreshedCache = {};
  final List<ScheduleInfo> requestedInfos = [];

  @override
  Future<Schedule> fetch({
    required ScheduleInfo info,
    required int week,
  }) async {
    requestedInfos.add(info);
    final schedule = await (_completers[week] ??= Completer<Schedule>()).future;
    refreshedCache[week] = schedule;
    return schedule;
  }

  @override
  Future<ScheduleCacheEntry?> getLocalSchedule({
    required ScheduleInfo info,
    required int week,
    int? academicYearStart,
  }) async =>
      cached[week];

  @override
  Future<ScheduleCacheEntry?> getClosestLocalSchedule({
    required ScheduleInfo info,
    required DateTime date,
  }) async =>
      null;

  void complete(int week, Schedule schedule) {
    final completer = _completers[week] ??= Completer<Schedule>();
    if (!completer.isCompleted) {
      completer.complete(schedule);
    }
  }

  bool hasPendingFetch(int week) =>
      _completers[week] != null && !_completers[week]!.isCompleted;
}

class _UnusedGroupRepository implements IGroupRepository {
  @override
  Future<List<Group>> fetchAll() => throw UnimplementedError();

  @override
  Future<List<Faculty>> fetchAllFaculties() => throw UnimplementedError();

  @override
  Future<Group> fetchGroupById(int groupId) => throw UnimplementedError();
}

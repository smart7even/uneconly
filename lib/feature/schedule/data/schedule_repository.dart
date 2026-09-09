import 'package:uneconly/feature/schedule/data/schedule_calendar_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

abstract class IScheduleRepository {
  /// Fetches fresh data and persists it before completing.
  ///
  /// Callers may stop waiting when the visible week changes, but an already
  /// started invocation is deliberately allowed to finish so its response is
  /// still useful during a later offline/cache-first visit.
  Future<Schedule> fetch({
    required ScheduleInfo info,
    required int week,
  });
  Future<ScheduleCacheEntry?> getLocalSchedule({
    required ScheduleInfo info,
    required int week,
    int? academicYearStart,
  });
  Future<ScheduleCacheEntry?> getClosestLocalSchedule({
    required ScheduleInfo info,
    required DateTime date,
  });
}

class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository({
    required final IScheduleNetworkDataProvider networkDataProvider,
    required final IScheduleLocalDataProvider localDataProvider,
    required final IScheduleCalendarDataProvider calendarDataProvider,
    required final ISettingsLocalDataProvider settingsLocalDataProvider,
  })  : _networkDataProvider = networkDataProvider,
        _localDataProvider = localDataProvider,
        _calendarDataProvider = calendarDataProvider,
        _settingsLocalDataProvider = settingsLocalDataProvider;

  final IScheduleNetworkDataProvider _networkDataProvider;
  final IScheduleLocalDataProvider _localDataProvider;
  final IScheduleCalendarDataProvider _calendarDataProvider;
  final ISettingsLocalDataProvider _settingsLocalDataProvider;
  final Map<({String scope, int week}), int> _startedFetchRevisions = {};
  final Map<({String scope, int week}), int> _completedFetchRevisions = {};
  final Map<({String scope, int week}), Future<void>> _cacheWriteChains = {};

  @override
  Future<Schedule> fetch({
    required ScheduleInfo info,
    required int week,
  }) async {
    final cacheKey = (scope: scheduleCacheScope(info), week: week);
    final revision = (_startedFetchRevisions[cacheKey] ?? 0) + 1;
    _startedFetchRevisions[cacheKey] = revision;

    Schedule schedule = await _networkDataProvider.fetch(
      info: info,
      week: week,
    );

    // A newer request for this exact schedule may already have completed.
    // Returning this response is harmless because the BLoC also guards UI
    // publication, but persisting it would roll the cache back. Merely starting
    // a newer request is not enough to discard this useful response: that
    // request may hang or fail. Different weeks/scopes have independent keys.
    if ((_completedFetchRevisions[cacheKey] ?? 0) > revision) {
      return schedule;
    }
    _completedFetchRevisions[cacheKey] = revision;

    await _persistLatestResponse(
      cacheKey: cacheKey,
      revision: revision,
      schedule: schedule,
    );

    if (_completedFetchRevisions[cacheKey] != revision) {
      return schedule;
    }

    final isSystemCalendarSyncingEnabled =
        await _settingsLocalDataProvider.isSystemCalendarSyncingEnabled();

    final userGroup = await _settingsLocalDataProvider.getGroup();

    final isUserGroup = info.map(
      group: (group) => group.shortGroupInfo.groupId == userGroup?.id,
      professor: (professor) => false,
    );

    if (isSystemCalendarSyncingEnabled && isUserGroup) {
      await _calendarDataProvider.saveSchedule(schedule);
    }

    return schedule;
  }

  Future<void> _persistLatestResponse({
    required ({String scope, int week}) cacheKey,
    required int revision,
    required Schedule schedule,
  }) {
    final previousWrite = _cacheWriteChains[cacheKey];

    Future<void> persistIfLatest() async {
      if (_completedFetchRevisions[cacheKey] != revision) {
        return;
      }
      await _localDataProvider.saveSchedule(schedule);
    }

    late final Future<void> currentWrite;
    currentWrite = previousWrite == null
        ? persistIfLatest()
        : previousWrite.then(
            (_) => persistIfLatest(),
            onError: (_, __) => persistIfLatest(),
          );
    _cacheWriteChains[cacheKey] = currentWrite;

    return currentWrite.whenComplete(() {
      if (identical(_cacheWriteChains[cacheKey], currentWrite)) {
        _cacheWriteChains.remove(cacheKey);
      }
    });
  }

  @override
  Future<ScheduleCacheEntry?> getLocalSchedule({
    required ScheduleInfo info,
    required int week,
    int? academicYearStart,
  }) {
    return _localDataProvider.getSchedule(
      week,
      info,
      academicYearStart,
    );
  }

  @override
  Future<ScheduleCacheEntry?> getClosestLocalSchedule({
    required ScheduleInfo info,
    required DateTime date,
  }) {
    return _localDataProvider.getClosestSchedule(date, info);
  }
}

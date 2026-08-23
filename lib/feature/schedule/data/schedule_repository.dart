import 'package:uneconly/feature/schedule/data/schedule_calendar_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

abstract class IScheduleRepository {
  Future<Schedule> fetch({
    required ScheduleInfo info,
    required int week,
  });
  Future<Schedule?> getLocalSchedule({
    required ScheduleInfo info,
    required int week,
    DateTime? periodStart,
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

  @override
  Future<Schedule> fetch({
    required ScheduleInfo info,
    required int week,
  }) async {
    Schedule schedule = await _networkDataProvider.fetch(
      info: info,
      week: week,
    );
    await _localDataProvider.saveSchedule(schedule);

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

  @override
  Future<Schedule?> getLocalSchedule({
    required ScheduleInfo info,
    required int week,
    DateTime? periodStart,
  }) {
    return _localDataProvider.getSchedule(
      week,
      info,
      periodStart,
    );
  }
}

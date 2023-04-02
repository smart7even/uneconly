import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleRepository {
  Future<Schedule> fetch({int? groupId, int? week});
  Future<Schedule?> getLocalSchedule({required int groupId, int? week});
}

class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository({
    required final IScheduleNetworkDataProvider networkDataProvider,
    required final IScheduleLocalDataProvider localDataProvider,
  })  : _networkDataProvider = networkDataProvider,
        _localDataProvider = localDataProvider;

  final IScheduleNetworkDataProvider _networkDataProvider;
  final IScheduleLocalDataProvider _localDataProvider;

  @override
  Future<Schedule> fetch({int? groupId, int? week}) async {
    Schedule schedule =
        await _networkDataProvider.fetch(groupId: groupId, week: week);
    await _localDataProvider.saveSchedule(schedule);

    return schedule;
  }

  @override
  Future<Schedule?> getLocalSchedule({required int groupId, int? week}) {
    final currentTime = DateTime.now();

    final requestedWeek = week ?? getStudyWeekNumber(currentTime, currentTime);

    return _localDataProvider.getSchedule(requestedWeek);
  }
}

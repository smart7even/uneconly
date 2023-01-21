import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleRepository {
  Future<Schedule> fetch({int? groupId, int? week});
}

class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository({
    required final IScheduleNetworkDataProvider networkDataProvider,
  }) : _networkDataProvider = networkDataProvider;

  final IScheduleNetworkDataProvider _networkDataProvider;

  @override
  Future<Schedule> fetch({int? groupId, int? week}) async {
    return _networkDataProvider.fetch(groupId: groupId, week: week);
  }
}

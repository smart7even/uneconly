import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleRepository {
  Future<Schedule> fetch({int? groupId, int? week});
}

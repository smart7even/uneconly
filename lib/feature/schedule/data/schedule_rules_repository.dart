import 'package:uneconly/feature/schedule/data/schedule_rules_local_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule_rule.dart';

abstract class IScheduleRulesRepository {
  Future<List<ScheduleRule>> getLocalScheduleRules(int groupId);
  Future<void> saveLocalScheduleRules(
    int groupId,
    List<ScheduleRule> scheduleRules,
  );
}

class ScheduleRulesRepository implements IScheduleRulesRepository {
  ScheduleRulesRepository({
    required final IScheduleRulesLocalDataProvider localDataProvider,
  }) : _localDataProvider = localDataProvider;

  final IScheduleRulesLocalDataProvider _localDataProvider;

  @override
  Future<List<ScheduleRule>> getLocalScheduleRules(int groupId) {
    return _localDataProvider.getScheduleRules(groupId);
  }

  @override
  Future<void> saveLocalScheduleRules(
    int groupId,
    List<ScheduleRule> scheduleRules,
  ) {
    return _localDataProvider.saveScheduleRules(groupId, scheduleRules);
  }
}

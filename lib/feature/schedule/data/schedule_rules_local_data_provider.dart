import 'package:drift/drift.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/feature/schedule/model/schedule_rule.dart';

abstract class IScheduleRulesLocalDataProvider {
  Future<List<ScheduleRule>> getScheduleRules(int groupId);
  Future<void> saveScheduleRules(int groupId, List<ScheduleRule> scheduleRules);
}

class ScheduleRulesLocalDataProvider
    implements IScheduleRulesLocalDataProvider {
  final MyDatabase _database;

  ScheduleRulesLocalDataProvider(this._database);

  @override
  Future<List<ScheduleRule>> getScheduleRules(int groupId) async {
    final scheduleRules = await (_database.select(_database.scheduleRules)
          ..where((tbl) => tbl.groupId.equals(groupId)))
        .get();

    return scheduleRules
        .map(
          (e) => ScheduleRule(
            id: e.id,
            groupId: e.groupId,
            lesson: e.lesson,
            lessonType: e.lessonType,
            professor: e.professor,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveScheduleRules(
    int groupId,
    List<ScheduleRule> scheduleRules,
  ) async {
    await (_database.scheduleRules.delete()
          ..where((tbl) => tbl.groupId.equals(groupId)))
        .go();

    await _database.scheduleRules.insertAll(
      scheduleRules.map(
        (e) => ScheduleRulesCompanion(
          groupId: Value(groupId),
          lesson: Value(e.lesson),
          lessonType: Value(e.lessonType),
          professor: Value(e.professor),
        ),
      ),
    );
  }
}

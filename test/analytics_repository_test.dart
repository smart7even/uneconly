import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';
import 'package:uneconly/common/logging/logging_repository.dart';

void main() {
  test(
    'home open reports the saved primary group with a stable schema',
    () async {
      final logger = _FakeLoggingRepository();
      final analytics = AnalyticsRepository(loggingRepository: logger);

      await analytics.logPrimaryGroupHomeOpen(
        groupId: 2601,
        groupName: '  БИ-2601  ',
        course: 1,
        facultyId: 1015,
      );

      expect(logger.events, hasLength(1));
      expect(logger.events.single.$1, 'schedule/home_open');
      expect(logger.events.single.$2, <String, Object>{
        'schema_version': 1,
        'relationship': 'primary',
        'scope': 'group',
        'group_id': '2601',
        'group_name': 'БИ-2601',
        'course': '1',
        'faculty_id': '1015',
      });
    },
  );

  test('home open bounds an invalid group name', () async {
    final logger = _FakeLoggingRepository();
    final analytics = AnalyticsRepository(loggingRepository: logger);

    await analytics.logPrimaryGroupHomeOpen(
      groupId: 2601,
      groupName: 'x' * 65,
      course: 1,
      facultyId: 1015,
    );

    expect(logger.events.single.$2?['group_name'], 'unknown');
  });

  test('analytics failure does not escape into the home flow', () async {
    final analytics = AnalyticsRepository(
      loggingRepository: _ThrowingLoggingRepository(),
    );

    await expectLater(
      analytics.logPrimaryGroupHomeOpen(
        groupId: 2601,
        groupName: 'БИ-2601',
        course: 1,
        facultyId: 1015,
      ),
      completes,
    );
  });

  test('share reports a bounded group and format contract', () async {
    final logger = _FakeLoggingRepository();
    final analytics = AnalyticsRepository(loggingRepository: logger);

    await analytics.logScheduleShare(
      stage: ScheduleShareStage.completed,
      surface: ScheduleSurface.home,
      scope: ScheduleScope.group,
      groupId: 2604,
      groupName: '  БИ-2604 ',
      format: ScheduleShareFormat.image,
      result: ScheduleShareResult.success,
    );

    expect(logger.events.single.$1, 'schedule/share');
    expect(logger.events.single.$2, {
      'schema_version': 1,
      'stage': 'completed',
      'surface': 'home',
      'schedule_scope': 'group',
      'group_id': '2604',
      'group_name': 'БИ-2604',
      'format': 'image',
      'result': 'success',
    });
  });

  test('professor share has no group attribution', () async {
    final logger = _FakeLoggingRepository();
    final analytics = AnalyticsRepository(loggingRepository: logger);

    await analytics.logScheduleShare(
      stage: ScheduleShareStage.chooserOpened,
      surface: ScheduleSurface.viewed,
      scope: ScheduleScope.professor,
    );

    expect(logger.events.single.$2, {
      'schema_version': 1,
      'stage': 'chooser_opened',
      'surface': 'viewed',
      'schedule_scope': 'professor',
    });
  });

  test('analytics failure does not escape into sharing', () async {
    final analytics = AnalyticsRepository(
      loggingRepository: _ThrowingLoggingRepository(),
    );

    await expectLater(
      analytics.logScheduleShare(
        stage: ScheduleShareStage.formatSelected,
        surface: ScheduleSurface.home,
        scope: ScheduleScope.group,
        format: ScheduleShareFormat.text,
      ),
      completes,
    );
  });

  test('week change records input method and public group dimension', () async {
    final logger = _FakeLoggingRepository();
    final analytics = AnalyticsRepository(loggingRepository: logger);

    await analytics.logScheduleWeekChange(
      source: ScheduleWeekChangeSource.button,
      direction: ScheduleWeekChangeDirection.next,
      surface: ScheduleSurface.home,
      scope: ScheduleScope.group,
      groupId: 2604,
      groupName: '  БИ-2604 ',
    );

    expect(logger.events.single.$1, 'schedule/week_change');
    expect(logger.events.single.$2, {
      'schema_version': 1,
      'source': 'button',
      'direction': 'next',
      'surface': 'home',
      'schedule_scope': 'group',
      'group_id': '2604',
      'group_name': 'БИ-2604',
    });
  });

  test('professor swipe has no group attribution', () async {
    final logger = _FakeLoggingRepository();
    final analytics = AnalyticsRepository(loggingRepository: logger);

    await analytics.logScheduleWeekChange(
      source: ScheduleWeekChangeSource.swipe,
      direction: ScheduleWeekChangeDirection.previous,
      surface: ScheduleSurface.viewed,
      scope: ScheduleScope.professor,
    );

    expect(logger.events.single.$2, {
      'schema_version': 1,
      'source': 'swipe',
      'direction': 'previous',
      'surface': 'viewed',
      'schedule_scope': 'professor',
    });
  });

  test('analytics failure does not block a week change', () async {
    final analytics = AnalyticsRepository(
      loggingRepository: _ThrowingLoggingRepository(),
    );

    await expectLater(
      analytics.logScheduleWeekChange(
        source: ScheduleWeekChangeSource.button,
        direction: ScheduleWeekChangeDirection.next,
        surface: ScheduleSurface.home,
        scope: ScheduleScope.group,
      ),
      completes,
    );
  });
}

class _FakeLoggingRepository implements ILoggingRepository {
  final events = <(String, Map<String, Object>?)>[];

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {}

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    events.add((eventName, attributes));
  }
}

class _ThrowingLoggingRepository implements ILoggingRepository {
  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {}

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    throw StateError('analytics unavailable');
  }
}

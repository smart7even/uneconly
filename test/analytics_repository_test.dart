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

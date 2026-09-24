import 'dart:developer';

import 'package:uneconly/common/logging/logging_repository.dart';

abstract class IAnalyticsRepository {
  Future<void> logPageOpen(String pageName, Map<String, dynamic> parameters);
  Future<void> logPageClose(String pageName, Map<String, dynamic> parameters);
  Future<void> logPrimaryGroupHomeOpen({
    required int groupId,
    required String groupName,
    required int course,
    required int facultyId,
  });
}

class AnalyticsRepository implements IAnalyticsRepository {
  final ILoggingRepository _loggingRepository;

  AnalyticsRepository({required ILoggingRepository loggingRepository})
    : _loggingRepository = loggingRepository;

  @override
  Future<void> logPageOpen(
    String pageName,
    Map<String, dynamic> parameters,
  ) async {
    await _loggingRepository.logEvent('page/open', {
      'page': _makePageInfo(pageName, parameters),
    });
  }

  @override
  Future<void> logPageClose(
    String pageName,
    Map<String, dynamic> parameters,
  ) async {
    await _loggingRepository.logEvent('page/close', {
      'page': _makePageInfo(pageName, parameters),
    });
  }

  @override
  Future<void> logPrimaryGroupHomeOpen({
    required int groupId,
    required String groupName,
    required int course,
    required int facultyId,
  }) async {
    try {
      await _loggingRepository.logEvent('schedule/home_open', {
        'schema_version': 1,
        'relationship': 'primary',
        'scope': 'group',
        'group_id': groupId.toString(),
        'group_name': _normalizeGroupName(groupName),
        'course': course.toString(),
        'faculty_id': facultyId.toString(),
      });
    } on Object catch (error, stackTrace) {
      // Analytics is supplementary and must never delay or block the home
      // schedule. Keep the failure local instead of feeding it back into the
      // product flow or recursively reporting it through the same logger.
      log(
        'Failed to report schedule/home_open',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Map<String, dynamic> _makePageInfo(
    String pageName,
    Map<String, dynamic>? parameters,
  ) {
    return {
      'page': {'name': pageName, 'parameters': parameters},
    };
  }

  String _normalizeGroupName(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty || normalized.length > 64) {
      return 'unknown';
    }
    return normalized;
  }
}

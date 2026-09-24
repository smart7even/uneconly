import 'dart:developer';

import 'package:uneconly/common/logging/logging_repository.dart';

enum ScheduleShareStage {
  chooserOpened,
  chooserDismissed,
  formatSelected,
  previewDismissed,
  sheetOpened,
  completed,
  failed,
}

enum ScheduleShareFormat { text, image }

enum ScheduleShareResult { success, dismissed, unavailable }

enum ScheduleSurface { home, viewed }

enum ScheduleScope { group, professor }

enum ScheduleWeekChangeSource { button, swipe }

enum ScheduleWeekChangeDirection { previous, next }

abstract class IAnalyticsRepository {
  Future<void> logPageOpen(String pageName, Map<String, dynamic> parameters);
  Future<void> logPageClose(String pageName, Map<String, dynamic> parameters);
  Future<void> logPrimaryGroupHomeOpen({
    required int groupId,
    required String groupName,
    required int course,
    required int facultyId,
  });
  Future<void> logScheduleShare({
    required ScheduleShareStage stage,
    required ScheduleSurface surface,
    required ScheduleScope scope,
    int? groupId,
    String? groupName,
    ScheduleShareFormat? format,
    ScheduleShareResult? result,
  });
  Future<void> logScheduleWeekChange({
    required ScheduleWeekChangeSource source,
    required ScheduleWeekChangeDirection direction,
    required ScheduleSurface surface,
    required ScheduleScope scope,
    int? groupId,
    String? groupName,
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

  @override
  Future<void> logScheduleShare({
    required ScheduleShareStage stage,
    required ScheduleSurface surface,
    required ScheduleScope scope,
    int? groupId,
    String? groupName,
    ScheduleShareFormat? format,
    ScheduleShareResult? result,
  }) async {
    try {
      await _loggingRepository.logEvent('schedule/share', {
        'schema_version': 1,
        'stage': switch (stage) {
          ScheduleShareStage.chooserOpened => 'chooser_opened',
          ScheduleShareStage.chooserDismissed => 'chooser_dismissed',
          ScheduleShareStage.formatSelected => 'format_selected',
          ScheduleShareStage.previewDismissed => 'preview_dismissed',
          ScheduleShareStage.sheetOpened => 'sheet_opened',
          ScheduleShareStage.completed => 'completed',
          ScheduleShareStage.failed => 'failed',
        },
        'surface': surface.name,
        'schedule_scope': scope.name,
        if (scope == ScheduleScope.group && groupId != null)
          'group_id': groupId.toString(),
        if (scope == ScheduleScope.group)
          'group_name': _normalizeGroupName(groupName ?? ''),
        if (format != null) 'format': format.name,
        if (result != null) 'result': result.name,
      });
    } on Object catch (error, stackTrace) {
      log(
        'Failed to report schedule/share',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logScheduleWeekChange({
    required ScheduleWeekChangeSource source,
    required ScheduleWeekChangeDirection direction,
    required ScheduleSurface surface,
    required ScheduleScope scope,
    int? groupId,
    String? groupName,
  }) async {
    try {
      await _loggingRepository.logEvent('schedule/week_change', {
        'schema_version': 1,
        'source': source.name,
        'direction': direction.name,
        'surface': surface.name,
        'schedule_scope': scope.name,
        if (scope == ScheduleScope.group && groupId != null)
          'group_id': groupId.toString(),
        if (scope == ScheduleScope.group)
          'group_name': _normalizeGroupName(groupName ?? ''),
      });
    } on Object catch (error, stackTrace) {
      log(
        'Failed to report schedule/week_change',
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

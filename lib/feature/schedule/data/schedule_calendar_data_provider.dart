import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

abstract class IScheduleCalendarDataProvider {
  Future<void> saveSchedule(Schedule schedule);
}

class ScheduleCalendarDataProvider implements IScheduleCalendarDataProvider {
  ScheduleCalendarDataProvider({
    required DeviceCalendarPlugin deviceCalendarPlugin,
    LessonChoiceRepository? lessonChoiceRepository,
  })  : _deviceCalendarPlugin = deviceCalendarPlugin,
        _lessonChoiceRepository = lessonChoiceRepository;

  final DeviceCalendarPlugin _deviceCalendarPlugin;
  final LessonChoiceRepository? _lessonChoiceRepository;

  Future<bool> _requestPermissions() async {
    final isAccessGranted = await _deviceCalendarPlugin.hasPermissions();

    if (!isAccessGranted.isSuccess || !isAccessGranted.data!) {
      final permissionGrantedResult =
          await _deviceCalendarPlugin.requestPermissions();

      if (!permissionGrantedResult.isSuccess ||
          permissionGrantedResult.data == null ||
          permissionGrantedResult.data == false) {
        return false;
      }
    }

    return true;
  }

  Future<Calendar?> _getCalendar(ScheduleInfo scheduleInfo) async {
    const calendarPrefix = 'Uneconly';

    final scheduleName = scheduleInfo.map(
      group: (group) => group.shortGroupInfo.groupName,
      professor: (professor) => professor.shortProfessorInfo.professorName,
    );

    final calendarName = '$calendarPrefix $scheduleName';

    var calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;

    var calendar = calendars?.firstWhereOrNull(
      (element) => element.name == calendarName,
    );

    if (calendar == null) {
      final createCalendarResult = await _deviceCalendarPlugin.createCalendar(
        calendarName,
      );
      if (!createCalendarResult.isSuccess) {
        l.v6('Calendar not created');

        return null;
      }

      calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data;
      calendar = calendars?.firstWhereOrNull(
        (element) => element.name == calendarName,
      );
    }

    if (calendar == null) {
      l.v6('Calendar not found');

      return null;
    }

    return calendar;
  }

  Future<void> _saveCurrentSchedule(
    Schedule schedule,
    Calendar calendar,
  ) async {
    final location = getLocation('Europe/Moscow');

    // Add events to calendar
    for (var daySchedule in schedule.daySchedules) {
      // Delete old events
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: TZDateTime.from(
            daySchedule.day,
            location,
          ),
          endDate: TZDateTime.from(
            daySchedule.day.add(
              const Duration(days: 1),
            ),
            location,
          ),
        ),
      );

      final oldEvents = eventsResult.data;

      if (oldEvents != null) {
        for (final event in oldEvents) {
          final eventId = event.eventId;

          if (eventId == null) {
            continue;
          }

          await _deviceCalendarPlugin.deleteEvent(
            calendar.id,
            eventId,
          );
        }
      }

      final clusters = clusterParallelLessons(
        daySchedule.lessons,
        combineAlternatives: true,
      );
      for (final cluster in clusters) {
        final lesson = _resolveLesson(schedule, cluster);
        final unresolved = cluster.hasAlternatives && lesson == null;
        final visibleLesson = lesson ?? cluster.lesson;
        final event = Event(
          calendar.id,
          location:
              unresolved ? null : cleanLessonLocation(visibleLesson.location),
          title: lessonDisplayName(visibleLesson),
          description: unresolved
              ? 'Выберите подгруппу в Uneconly'
              : visibleLesson.professor,
          start: TZDateTime.from(
            visibleLesson.start,
            location,
          ),
          end: TZDateTime.from(
            visibleLesson.end,
            location,
          ),
          reminders: [
            Reminder(
              minutes: 15,
            ),
          ],
        );
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
      }
    }
  }

  Lesson? _resolveLesson(Schedule schedule, LessonCluster cluster) {
    if (!cluster.hasAlternatives) return cluster.lesson;
    final repository = _lessonChoiceRepository;
    if (repository == null) return null;
    final resolution = repository.resolve(
      info: schedule.info,
      lesson: cluster.lesson,
    );
    if (resolution == null) return null;
    for (final lesson in cluster.alternatives) {
      if (lessonAlternativeId(lesson) == resolution.alternativeId) {
        return lesson;
      }
    }
    return null;
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    final permissionGranted = await _requestPermissions();

    if (!permissionGranted) {
      l.v6('Permission not granted');

      return;
    }

    // Create calendar Uneconly

    final calendar = await _getCalendar(schedule.info);

    if (calendar == null) {
      l.v6('Calendar not found or not created');

      return;
    }

    // Save schedule to calendar
    await _saveCurrentSchedule(
      schedule,
      calendar,
    );
  }
}

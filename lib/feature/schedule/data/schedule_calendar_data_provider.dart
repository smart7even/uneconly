import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

abstract class IScheduleCalendarDataProvider {
  Future<void> saveSchedule(Schedule schedule);
}

class ScheduleCalendarDataProvider implements IScheduleCalendarDataProvider {
  ScheduleCalendarDataProvider({
    required DeviceCalendarPlugin deviceCalendarPlugin,
  }) : _deviceCalendarPlugin = deviceCalendarPlugin;

  final DeviceCalendarPlugin _deviceCalendarPlugin;

  Future<bool> _requestPermissions() async {
    final isAccessGranted = await _deviceCalendarPlugin.hasPermissions();

    if (!isAccessGranted.isSuccess || !isAccessGranted.data!) {
      final permissionGrantedResult =
          await _deviceCalendarPlugin.requestPermissions();

      if (!permissionGrantedResult.isSuccess ||
          !permissionGrantedResult.data!) {
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
          await _deviceCalendarPlugin.deleteEvent(
            calendar.id,
            event.eventId!,
          );
        }
      }

      for (final lesson in daySchedule.lessons) {
        final event = Event(
          calendar.id,
          location: lesson.location,
          title: lesson.name,
          description: lesson.professor,
          start: TZDateTime.from(
            lesson.start,
            location,
          ),
          end: TZDateTime.from(
            lesson.end,
            location,
          ),
        );
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
      }
    }
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

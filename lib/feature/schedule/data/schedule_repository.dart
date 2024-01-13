import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleRepository {
  Future<Schedule> fetch({required int groupId, required int week});
  Future<Schedule?> getLocalSchedule({required int groupId, required int week});
}

class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository({
    required final IScheduleNetworkDataProvider networkDataProvider,
    required final IScheduleLocalDataProvider localDataProvider,
  })  : _networkDataProvider = networkDataProvider,
        _localDataProvider = localDataProvider;

  final IScheduleNetworkDataProvider _networkDataProvider;
  final IScheduleLocalDataProvider _localDataProvider;

  @override
  Future<Schedule> fetch({required int groupId, required int week}) async {
    Schedule schedule =
        await _networkDataProvider.fetch(groupId: groupId, week: week);
    await _localDataProvider.saveSchedule(schedule);

    DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

    final isAccessGranted = await deviceCalendarPlugin.hasPermissions();

    if (!isAccessGranted.isSuccess || !isAccessGranted.data!) {
      final permissionGrantedResult =
          await deviceCalendarPlugin.requestPermissions();

      if (!permissionGrantedResult.isSuccess ||
          !permissionGrantedResult.data!) {
        throw Exception('Permission not granted');
      }
    }

    final location = getLocation('Europe/Moscow');

    // Create calendar Uneconly

    var calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;

    var calendar = calendars?.firstWhereOrNull(
      (element) => element.name == 'Uneconly',
    );

    if (calendar == null) {
      final createCalendarResult = await deviceCalendarPlugin.createCalendar(
        'Uneconly',
      );
      if (!createCalendarResult.isSuccess) {
        throw Exception('Calendar not created');
      }

      calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data;
      calendar = calendars?.firstWhereOrNull(
        (element) => element.name == 'Uneconly',
      );
    }

    if (calendar == null) {
      throw Exception('Calendar not found');
    }

    // Add events to calendar
    for (var daySchedule in schedule.daySchedules) {
      // Delete old events
      final eventsResult = await deviceCalendarPlugin.retrieveEvents(
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
          final result = await deviceCalendarPlugin.deleteEvent(
            calendar.id,
            event.eventId!,
          );
          l.v6(result.toString());
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
        final result = await deviceCalendarPlugin.createOrUpdateEvent(event);
        l.v6(result.toString());
      }
    }

    return schedule;
  }

  @override
  Future<Schedule?> getLocalSchedule({
    required int groupId,
    required int week,
  }) {
    return _localDataProvider.getSchedule(
      week,
      groupId,
    );
  }
}

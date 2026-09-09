import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/ios_calendar_sync_bridge.dart';
import 'package:uneconly/feature/schedule/data/schedule_calendar_data_provider.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2604, groupName: 'БИ-2604'),
  );

  Schedule makeSchedule(List<DaySchedule> days) => Schedule(
    week: 2,
    info: info,
    daySchedules: days,
    academicYearStart: 2026,
    periodStart: DateTime(2026, 9, 7),
    periodEnd: DateTime(2026, 9, 13),
  );

  test(
    'unpublished schedules do not request access or clear calendar data',
    () async {
      final plugin = _GrantedCalendarPlugin();
      final bridge = _RecordingIosBridge();
      final provider = ScheduleCalendarDataProvider(
        deviceCalendarPlugin: plugin,
        iosCalendarSyncBridge: bridge,
        useIosBatchSync: true,
      );

      await provider.saveSchedule(makeSchedule(const []));

      expect(plugin.permissionChecks, 0);
      expect(bridge.calls, isEmpty);
    },
  );

  test(
    'a published all-free week clears its full calendar date range',
    () async {
      final plugin = _GrantedCalendarPlugin();
      final bridge = _RecordingIosBridge();
      final provider = ScheduleCalendarDataProvider(
        deviceCalendarPlugin: plugin,
        iosCalendarSyncBridge: bridge,
        useIosBatchSync: true,
      );
      final days = List.generate(
        7,
        (index) => DaySchedule.empty(DateTime(2026, 9, 7 + index)),
      );

      await provider.saveSchedule(makeSchedule(days));

      expect(plugin.permissionChecks, 1);
      expect(bridge.calls, hasLength(1));
      expect(bridge.calls.single.start, DateTime(2026, 9, 7));
      expect(bridge.calls.single.end, DateTime(2026, 9, 14));
      expect(bridge.calls.single.events, isEmpty);
    },
  );

  test('iOS batch sync sends lesson details in one replacement call', () async {
    final plugin = _GrantedCalendarPlugin();
    final bridge = _RecordingIosBridge();
    final provider = ScheduleCalendarDataProvider(
      deviceCalendarPlugin: plugin,
      iosCalendarSyncBridge: bridge,
      useIosBatchSync: true,
    );
    final day = DateTime(2026, 9, 9);
    final lesson = Lesson(
      name: 'История России',
      day: day,
      dayOfWeek: 'Среда',
      start: DateTime(2026, 9, 9, 9),
      end: DateTime(2026, 9, 9, 10, 30),
      professor: 'Преподаватель',
      location: 'ауд. 2088 · Грибоедова 30/32',
      lessonType: 'Лекция',
      group: 'БИ-2604',
      professorId: 1,
    );

    await provider.saveSchedule(
      makeSchedule([
        DaySchedule(day: day, lessons: [lesson]),
      ]),
    );

    expect(bridge.calls, hasLength(1));
    expect(bridge.calls.single.events, hasLength(1));
    final event = bridge.calls.single.events.single;
    expect(event.title, contains('История России'));
    expect(event.description, 'Преподаватель');
    expect(event.location, contains('2088'));
    expect(event.start, lesson.start);
    expect(event.end, lesson.end);
  });
}

class _GrantedCalendarPlugin extends DeviceCalendarPlugin {
  _GrantedCalendarPlugin() : super.private();

  int permissionChecks = 0;

  @override
  Future<Result<bool>> hasPermissions() async {
    permissionChecks += 1;
    return Result<bool>()..data = true;
  }
}

class _RecordingIosBridge implements IIosCalendarSyncBridge {
  final calls = <_BridgeCall>[];

  @override
  Future<void> replaceEvents({
    required String calendarName,
    required DateTime start,
    required DateTime end,
    required List<CalendarSyncEvent> events,
  }) async {
    calls.add(
      _BridgeCall(
        calendarName: calendarName,
        start: start,
        end: end,
        events: events,
      ),
    );
  }
}

class _BridgeCall {
  const _BridgeCall({
    required this.calendarName,
    required this.start,
    required this.end,
    required this.events,
  });

  final String calendarName;
  final DateTime start;
  final DateTime end;
  final List<CalendarSyncEvent> events;
}

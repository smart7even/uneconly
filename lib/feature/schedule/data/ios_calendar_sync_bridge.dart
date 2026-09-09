import 'package:flutter/services.dart';

class CalendarSyncEvent {
  const CalendarSyncEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
  });

  final String title;
  final String? description;
  final String? location;
  final DateTime start;
  final DateTime end;

  Map<String, Object?> toMap() => <String, Object?>{
    'title': title,
    'description': description,
    'location': location,
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
  };
}

abstract interface class IIosCalendarSyncBridge {
  Future<void> replaceEvents({
    required String calendarName,
    required DateTime start,
    required DateTime end,
    required List<CalendarSyncEvent> events,
  });
}

class IosCalendarSyncBridge implements IIosCalendarSyncBridge {
  const IosCalendarSyncBridge({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const _channelName = 'com.roadmapik.uneconly/calendar_sync';

  final MethodChannel _channel;

  @override
  Future<void> replaceEvents({
    required String calendarName,
    required DateTime start,
    required DateTime end,
    required List<CalendarSyncEvent> events,
  }) async {
    await _channel.invokeMethod<void>('replaceEvents', <String, Object?>{
      'calendarName': calendarName,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'events': events.map((event) => event.toMap()).toList(growable: false),
    });
  }
}

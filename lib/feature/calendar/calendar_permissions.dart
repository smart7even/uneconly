import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

Future<bool> requestCalendarPermission() async {
  try {
    final plugin = DeviceCalendarPlugin();
    var result = await plugin.hasPermissions();
    if (result.isSuccess && result.data == true) return true;
    result = await plugin.requestPermissions();
    return result.isSuccess && result.data == true;
  } on PlatformException {
    return false;
  }
}

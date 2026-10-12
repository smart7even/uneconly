import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

String telemetryId() => List.generate(
  16,
  (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// Random app-install identity, shared by API diagnostics and Sentry.
Future<String> installationId(SharedPreferences preferences) async {
  final stored = preferences.getString('telemetry.installation_id');
  if (stored != null && RegExp(r'^[a-f0-9]{32}$').hasMatch(stored)) {
    return stored;
  }
  final id = telemetryId();
  await preferences.setString('telemetry.installation_id', id);
  return id;
}

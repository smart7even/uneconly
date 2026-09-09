import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/push/push_notification_service.dart';

void main() {
  late SharedPreferences preferences;
  late _FakeLoggingRepository loggingRepository;
  late _FakePushSdk pushSdk;
  late _FakeAndroidPermissionRequester androidPermissionRequester;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    loggingRepository = _FakeLoggingRepository();
    pushSdk = _FakePushSdk();
    androidPermissionRequester = _FakeAndroidPermissionRequester();
  });

  tearDown(() async {
    await pushSdk.dispose();
  });

  test('activates and asks for Android notification permission only once',
      () async {
    final service = AppMetricaPushNotificationService(
      preferences: preferences,
      loggingRepository: loggingRepository,
      pushSdk: pushSdk,
      androidPermissionRequester: androidPermissionRequester,
      platform: PushPlatform.android,
    );

    await service.activate();
    await service.requestPermissionIfNeeded();
    await service.requestPermissionIfNeeded();

    expect(pushSdk.activateCalls, 1);
    expect(pushSdk.iosPermissionCalls, 0);
    expect(androidPermissionRequester.calls, 1);
    expect(
      preferences.getBool(
        AppMetricaPushNotificationService.permissionPromptShownKey,
      ),
      isTrue,
    );

    await service.dispose();
  });

  test('uses the SDK permission request on iOS', () async {
    final service = AppMetricaPushNotificationService(
      preferences: preferences,
      loggingRepository: loggingRepository,
      pushSdk: pushSdk,
      androidPermissionRequester: androidPermissionRequester,
      platform: PushPlatform.ios,
    );

    await service.activate();
    await service.requestPermissionIfNeeded();

    expect(pushSdk.iosPermissionCalls, 1);
    expect(androidPermissionRequester.calls, 0);

    await service.dispose();
  });

  test('a push activation failure never blocks app initialization', () async {
    pushSdk.activationError = StateError('activation failed');
    final service = AppMetricaPushNotificationService(
      preferences: preferences,
      loggingRepository: loggingRepository,
      pushSdk: pushSdk,
      androidPermissionRequester: androidPermissionRequester,
      platform: PushPlatform.android,
    );

    await service.activate();
    await service.requestPermissionIfNeeded();

    expect(androidPermissionRequester.calls, 0);
    expect(loggingRepository.errors, hasLength(1));
    expect(
      preferences.getBool(
        AppMetricaPushNotificationService.permissionPromptShownKey,
      ),
      isNull,
    );

    await service.dispose();
  });

  test('unsupported platforms do not activate or request permission', () async {
    final service = AppMetricaPushNotificationService(
      preferences: preferences,
      loggingRepository: loggingRepository,
      pushSdk: pushSdk,
      androidPermissionRequester: androidPermissionRequester,
      platform: PushPlatform.unsupported,
    );

    await service.activate();
    await service.requestPermissionIfNeeded();

    expect(pushSdk.activateCalls, 0);
    expect(androidPermissionRequester.calls, 0);
    expect(pushSdk.iosPermissionCalls, 0);
  });
}

class _FakePushSdk implements IPushSdk {
  final _tokens = StreamController<Map<String, String?>>.broadcast();
  final _pushClicks = StreamController<void>.broadcast();

  int activateCalls = 0;
  int iosPermissionCalls = 0;
  Object? activationError;

  @override
  Stream<void> get pushClickStream => _pushClicks.stream;

  @override
  Stream<Map<String, String?>> get tokenStream => _tokens.stream;

  @override
  Future<void> activate() async {
    activateCalls++;
    if (activationError case final error?) throw error;
  }

  @override
  Future<void> requestIosPermission() async {
    iosPermissionCalls++;
  }

  Future<void> dispose() async {
    await _tokens.close();
    await _pushClicks.close();
  }
}

class _FakeAndroidPermissionRequester
    implements IAndroidNotificationPermissionRequester {
  int calls = 0;

  @override
  Future<bool> requestPermission() async {
    calls++;
    return true;
  }
}

class _FakeLoggingRepository implements ILoggingRepository {
  final errors = <Object>[];

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    errors.add(exception);
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {}
}

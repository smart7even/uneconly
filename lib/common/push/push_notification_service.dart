import 'dart:async';

import 'package:appmetrica_push_plugin/appmetrica_push_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';

abstract interface class IPushNotificationService {
  Future<void> activate();

  Future<void> requestPermissionIfNeeded();

  Future<void> dispose();
}

abstract interface class IPushSdk {
  Stream<Map<String, String?>> get tokenStream;

  Stream<void> get pushClickStream;

  Future<void> activate();

  Future<void> requestIosPermission();
}

abstract interface class IAndroidNotificationPermissionRequester {
  Future<bool> requestPermission();
}

enum PushPlatform { android, ios, unsupported }

class AppMetricaPushSdk implements IPushSdk {
  const AppMetricaPushSdk();

  @override
  Stream<Map<String, String?>> get tokenStream => AppMetricaPush.tokenStream;

  @override
  Stream<void> get pushClickStream =>
      AppMetricaPush.pushClickStream.map((_) {});

  @override
  Future<void> activate() => AppMetricaPush.activate();

  @override
  Future<void> requestIosPermission() => AppMetricaPush.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
}

class MethodChannelAndroidNotificationPermissionRequester
    implements IAndroidNotificationPermissionRequester {
  const MethodChannelAndroidNotificationPermissionRequester();

  static const _channel = MethodChannel(
    'com.roadmapik.uneconly/notification_permission',
  );

  @override
  Future<bool> requestPermission() async =>
      await _channel.invokeMethod<bool>('requestPermission') ?? false;
}

class AppMetricaPushNotificationService implements IPushNotificationService {
  AppMetricaPushNotificationService({
    required SharedPreferences preferences,
    required ILoggingRepository loggingRepository,
    IPushSdk pushSdk = const AppMetricaPushSdk(),
    IAndroidNotificationPermissionRequester androidPermissionRequester =
        const MethodChannelAndroidNotificationPermissionRequester(),
    PushPlatform? platform,
  })  : _preferences = preferences,
        _loggingRepository = loggingRepository,
        _pushSdk = pushSdk,
        _androidPermissionRequester = androidPermissionRequester,
        _platform = platform ?? _currentPlatform();

  static const permissionPromptShownKey =
      'push_notification_permission_prompt_shown_v1';

  final SharedPreferences _preferences;
  final ILoggingRepository _loggingRepository;
  final IPushSdk _pushSdk;
  final IAndroidNotificationPermissionRequester _androidPermissionRequester;
  final PushPlatform _platform;

  StreamSubscription<Map<String, String?>>? _tokenSubscription;
  StreamSubscription<void>? _pushClickSubscription;
  bool _isActivated = false;

  @override
  Future<void> activate() async {
    if (_platform == PushPlatform.unsupported || _isActivated) return;

    try {
      _tokenSubscription = _pushSdk.tokenStream.listen(
        (tokens) {
          final registeredProviderCount =
              tokens.values.where((token) => token?.isNotEmpty ?? false).length;
          l.v6(
            'Push token updated for $registeredProviderCount provider(s)',
          );
        },
        onError: _logStreamError,
      );
      _pushClickSubscription = _pushSdk.pushClickStream.listen(
        (_) => l.v6('Push notification opened'),
        onError: _logStreamError,
      );

      await _pushSdk.activate();
      _isActivated = true;
    } on Object catch (error, stackTrace) {
      await _cancelSubscriptions();
      await _loggingRepository.logError(
        error,
        stackTrace,
        hint: 'Failed to activate AppMetrica Push SDK',
      );
    }
  }

  @override
  Future<void> requestPermissionIfNeeded() async {
    if (!_isActivated ||
        _preferences.getBool(permissionPromptShownKey) == true) {
      return;
    }

    try {
      switch (_platform) {
        case PushPlatform.android:
          await _androidPermissionRequester.requestPermission();
          break;
        case PushPlatform.ios:
          await _pushSdk.requestIosPermission();
          break;
        case PushPlatform.unsupported:
          return;
      }

      await _preferences.setBool(permissionPromptShownKey, true);
    } on Object catch (error, stackTrace) {
      await _loggingRepository.logError(
        error,
        stackTrace,
        hint: 'Failed to request push notification permission',
      );
    }
  }

  @override
  Future<void> dispose() => _cancelSubscriptions();

  Future<void> _cancelSubscriptions() async {
    await _tokenSubscription?.cancel();
    await _pushClickSubscription?.cancel();
    _tokenSubscription = null;
    _pushClickSubscription = null;
  }

  void _logStreamError(Object error, StackTrace stackTrace) {
    _loggingRepository.logError(
      error,
      stackTrace,
      hint: 'AppMetrica Push stream failed',
    );
  }

  static PushPlatform _currentPlatform() {
    if (kIsWeb) return PushPlatform.unsupported;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => PushPlatform.android,
      TargetPlatform.iOS => PushPlatform.ios,
      _ => PushPlatform.unsupported,
    };
  }
}

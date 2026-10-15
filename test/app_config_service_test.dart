import 'dart:async';
import 'dart:convert';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_config.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/feature/schedule/data/app_config_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/app_config_service.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppConfig config({
    required bool autoScroll,
    int revision = 1,
    bool roomMap = false,
  }) => AppConfig(
    roomMapButtonEnabled: roomMap,
    roomMapCaptionEnabled: roomMap,
    scheduleAutoScrollToday: autoScroll,
    revision: revision,
    refreshIntervalSeconds: 300,
    payload: {'schedule_auto_scroll_today': autoScroll},
  );

  for (final cachedMode in <String?>[
    null,
    'off',
    'appmetrica',
    'sentry',
    'both',
  ]) {
    test(
      'startup routing respects ${cachedMode ?? "built-in both"} during failed first fetch',
      () async {
        final preferences = await SharedPreferences.getInstance();
        if (cachedMode != null) {
          await preferences.setString(
            AppConfigService.cacheKeyForGroup(42),
            jsonEncode({
              'cache_version': 1,
              'group_id': 42,
              'config': {
                'payload': {
                  'telemetry': {
                    'mode': cachedMode,
                    'sentry_dsn': TelemetryConfig.startupSentryDsn,
                  },
                },
              },
            }),
          );
        }
        final a = _RecordingSink(), s = _RecordingSink();
        final router = RoutingLoggingRepository(appmetrica: a, sentry: s);
        await router.logEvent('appOpen', {'sequence': 1});
        final network = _ControllableAppConfigNetwork();
        final service = AppConfigService(
          preferences: preferences,
          networkDataProvider: network,
          platform: 'test',
        );
        addTearDown(service.dispose);
        service.addListener(() => router.configure(service.current.telemetry));
        service.start(groupId: 42);
        router.configure(service.current.telemetry);
        await router.drain();
        network.requests.single.completer.completeError(Exception('offline'));
        await service.refreshIfDue(force: true);
        await router.logEvent('page/open', {'sequence': 2});
        await router.drain();
        final mode = cachedMode ?? 'both';
        expect(
          a.events,
          mode == 'both' || mode == 'appmetrica'
              ? ['appOpen', 'page/open']
              : isEmpty,
        );
        expect(
          s.events,
          mode == 'both' || mode == 'sentry'
              ? ['appOpen', 'page/open']
              : isEmpty,
        );
        expect(service.current.scheduleAutoScrollToday, isFalse);
        if (mode == 'both') expect(a.attributes, s.attributes);
        // An identical remote policy must not replay (or lose) startup events.
        final refresh = service.refreshIfDue(force: true);
        network.requests.last.completer.complete(
          AppConfig.fromJson({
            'payload': {
              'telemetry': {
                'mode': mode,
                'sentry_dsn': TelemetryConfig.startupSentryDsn,
              },
            },
          }),
        );
        await refresh;
        await router.drain();
        expect(
          a.events.where((e) => e == 'appOpen').length,
          mode == 'both' || mode == 'appmetrica' ? 1 : 0,
        );
        expect(
          s.events.where((e) => e == 'appOpen').length,
          mode == 'both' || mode == 'sentry' ? 1 : 0,
        );
      },
    );
  }

  test(
    'cached config is available synchronously while refresh is pending',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final cached = config(autoScroll: false, revision: 4);
      await preferences.setString(
        AppConfigService.cacheKeyForGroup(42),
        jsonEncode({
          'cache_version': 1,
          'group_id': 42,
          'config': cached.toJson(includeSafetyFlags: false),
        }),
      );
      final network = _ControllableAppConfigNetwork();
      final service = AppConfigService(
        preferences: preferences,
        networkDataProvider: network,
        platform: 'test',
      );
      addTearDown(service.dispose);

      service.start(groupId: 42);

      expect(service.current.scheduleAutoScrollToday, isFalse);
      expect(service.current.revision, 4);
      expect(network.requests, hasLength(1));
      expect(network.requests.single.groupId, 42);
      expect(network.requests.single.platform, 'test');

      network.requests.single.completer.complete(
        config(autoScroll: true, revision: 5),
      );
      await service.refreshIfDue(force: true);

      expect(service.current.scheduleAutoScrollToday, isTrue);
      expect(service.current.revision, 5);
    },
  );

  test(
    'failed refresh keeps the cached value and does not duplicate requests',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final cached = config(autoScroll: false, revision: 2);
      await preferences.setString(
        AppConfigService.cacheKeyForGroup(7),
        jsonEncode({
          'cache_version': 1,
          'group_id': 7,
          'config': cached.toJson(includeSafetyFlags: false),
        }),
      );
      final network = _ControllableAppConfigNetwork();
      final service = AppConfigService(
        preferences: preferences,
        networkDataProvider: network,
        platform: 'test',
      );
      addTearDown(service.dispose);

      service.start(groupId: 7);
      final secondRefresh = service.refreshIfDue(force: true);
      expect(network.requests, hasLength(1));
      network.requests.single.completer.completeError(Exception('offline'));
      await secondRefresh;

      expect(service.current, cached);
    },
  );

  test(
    'cache is isolated by primary group and safety flags are not restored',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final network = _ControllableAppConfigNetwork();
      final service = AppConfigService(
        preferences: preferences,
        networkDataProvider: network,
        platform: 'test',
      );
      addTearDown(service.dispose);

      service.start(groupId: 1);
      network.requests.single.completer.complete(
        config(autoScroll: false, revision: 3, roomMap: true),
      );
      await service.refreshIfDue(force: true);

      final nextNetwork = _ControllableAppConfigNetwork();
      final nextLaunch = AppConfigService(
        preferences: preferences,
        networkDataProvider: nextNetwork,
        platform: 'test',
      );
      addTearDown(nextLaunch.dispose);
      nextLaunch.start(groupId: 1);

      expect(nextLaunch.current.scheduleAutoScrollToday, isFalse);
      expect(nextLaunch.current.roomMapButtonEnabled, isFalse);
      expect(nextLaunch.current.roomMapCaptionEnabled, isFalse);

      nextLaunch.start(groupId: 2);
      expect(nextLaunch.current, const AppConfig.safeDefaults());
    },
  );

  test(
    'group change discards an old response and refreshes the new group',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final network = _ControllableAppConfigNetwork();
      final service = AppConfigService(
        preferences: preferences,
        networkDataProvider: network,
        platform: 'test',
      );
      addTearDown(service.dispose);

      service.start(groupId: 1);
      expect(network.requests, hasLength(1));

      service.start(groupId: 2);
      expect(service.current, const AppConfig.safeDefaults());
      network.requests.single.completer.complete(
        config(autoScroll: false, revision: 10),
      );
      await pumpEventQueue();

      expect(network.requests, hasLength(2));
      expect(network.requests.last.groupId, 2);
      expect(service.current, const AppConfig.safeDefaults());

      network.requests.last.completer.complete(
        config(autoScroll: true, revision: 11),
      );
      await service.refreshIfDue(force: true);

      expect(service.current.revision, 11);
      expect(service.current.scheduleAutoScrollToday, isTrue);
    },
  );
}

class _AppConfigRequest {
  _AppConfigRequest({required this.groupId, required this.platform});

  final int? groupId;
  final String platform;
  final Completer<AppConfig> completer = Completer<AppConfig>();
}

class _ControllableAppConfigNetwork implements IAppConfigNetworkDataProvider {
  final requests = <_AppConfigRequest>[];

  @override
  Future<AppConfig> fetch({required int? groupId, required String platform}) {
    final request = _AppConfigRequest(groupId: groupId, platform: platform);
    requests.add(request);
    return request.completer.future;
  }
}

class _RecordingSink implements TelemetrySink {
  final events = <String>[];
  final attributes = <Map<String, Object>?>[];
  @override
  Future<void> configure(TelemetryConfig config) async {}
  @override
  Future<void> logEvent(String eventName, [Map<String, Object>? attrs]) async {
    events.add(eventName);
    attributes.add(attrs);
  }

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {}
}

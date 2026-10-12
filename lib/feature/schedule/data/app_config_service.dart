import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/feature/schedule/data/app_config_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

class AppConfigService extends ChangeNotifier with WidgetsBindingObserver {
  AppConfigService({
    required SharedPreferences preferences,
    required IAppConfigNetworkDataProvider networkDataProvider,
    String? platform,
  }) : _preferences = preferences,
       _networkDataProvider = networkDataProvider,
       _platform = platform ?? Platform.operatingSystem {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _cacheVersion = 1;
  static const _fallbackRefreshInterval = Duration(minutes: 5);

  final SharedPreferences _preferences;
  final IAppConfigNetworkDataProvider _networkDataProvider;
  final String _platform;

  AppConfig _current = const AppConfig.safeDefaults();
  AppConfig get current => _current;

  bool get isStarted => _started;
  bool _started = false;
  bool _disposed = false;

  int? _groupId;
  DateTime? _nextRefreshAt;
  Future<void>? _refreshInFlight;
  int? _refreshGroupId;
  Timer? _refreshTimer;

  static String cacheKeyForGroup(int? groupId) =>
      'appConfig.cache.v$_cacheVersion.group.$groupId';

  void start({int? groupId}) {
    if (_started && _groupId == groupId) {
      unawaited(refreshIfDue());
      return;
    }

    _refreshTimer?.cancel();
    _started = true;
    _groupId = groupId;
    _nextRefreshAt = DateTime.now();
    _replaceCurrent(_readCached(groupId));
    unawaited(refreshIfDue(force: true));
  }

  Future<void> refreshIfDue({bool force = false}) async {
    final groupId = _groupId;
    if (!_started || _disposed) return;

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      final inFlightGroupId = _refreshGroupId;
      await inFlight;
      if (inFlightGroupId != groupId && _groupId == groupId) {
        await refreshIfDue(force: force);
      }
      return;
    }

    final now = DateTime.now();
    if (!force && _nextRefreshAt != null && now.isBefore(_nextRefreshAt!)) {
      _scheduleRefresh(_nextRefreshAt!.difference(now));
      return;
    }

    final refresh = _performRefresh(groupId);
    _refreshInFlight = refresh;
    _refreshGroupId = groupId;
    try {
      await refresh;
    } finally {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
        _refreshGroupId = null;
      }
    }
  }

  Future<void> _performRefresh(int? groupId) async {
    var nextDelay = _fallbackRefreshInterval;
    try {
      final config = await _networkDataProvider.fetch(
        groupId: groupId,
        platform: _platform,
      );
      if (_disposed || _groupId != groupId) return;

      if (config.revision < _current.revision) {
        throw const FormatException('Stale app config revision');
      }
      await _preferences.setString(
        cacheKeyForGroup(groupId),
        jsonEncode({
          'cache_version': _cacheVersion,
          'group_id': groupId,
          // Safety-sensitive room-map switches intentionally fail closed at
          // every process start; remote experiment payloads remain cached.
          'config': config.toJson(includeSafetyFlags: false),
        }),
      );
      if (_disposed || _groupId != groupId) return;
      _replaceCurrent(config);
      nextDelay = Duration(seconds: config.refreshIntervalSeconds);
    } on Object catch (error, stackTrace) {
      // A background config failure must never replace cache or affect UI.
      l.w('App config refresh failed: $error', stackTrace);
    } finally {
      if (!_disposed && _groupId == groupId) {
        _nextRefreshAt = DateTime.now().add(nextDelay);
        _scheduleRefresh(nextDelay);
      }
    }
  }

  AppConfig _readCached(int? groupId) {
    final encoded = _preferences.getString(cacheKeyForGroup(groupId));
    if (encoded == null) return const AppConfig.safeDefaults();

    try {
      final envelope = jsonDecode(encoded);
      if (envelope is! Map<String, dynamic> ||
          envelope['cache_version'] != _cacheVersion ||
          envelope['group_id'] != groupId ||
          envelope['config'] is! Map) {
        return const AppConfig.safeDefaults();
      }
      return AppConfig.fromJson(
        Map<String, dynamic>.from(envelope['config'] as Map),
      );
    } on Object catch (error, stackTrace) {
      l.w('Cached app config is invalid: $error', stackTrace);
      return const AppConfig.safeDefaults();
    }
  }

  void _replaceCurrent(AppConfig value) {
    if (_current == value) return;
    _current = value;
    notifyListeners();
  }

  void _scheduleRefresh(Duration delay) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(delay, () {
      unawaited(refreshIfDue(force: true));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refreshIfDue());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }
}

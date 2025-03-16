import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final IAnalyticsRepository _analyticsRepository;

  AppNavigatorObserver({
    required IAnalyticsRepository analyticsRepository,
  }) : _analyticsRepository = analyticsRepository;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    final routeArguments = route.settings.arguments;

    if (routeName != null && routeArguments is Map<String, dynamic>) {
      log('didPush ${routeName} ${routeArguments}');
      _analyticsRepository.logPageOpen(
        routeName,
        routeArguments,
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    final routeArguments = route.settings.arguments;

    if (routeName != null && routeArguments is Map<String, dynamic>) {
      log('didPop ${routeName} ${routeArguments}');
      _analyticsRepository.logPageClose(
        routeName,
        routeArguments,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    final routeArguments = route.settings.arguments;

    if (routeName != null && routeArguments is Map<String, dynamic>) {
      log('didRemove ${routeName} ${routeArguments}');
      _analyticsRepository.logPageClose(
        routeName,
        routeArguments,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final oldRouteName = oldRoute?.settings.name;
    final oldRouteArguments = oldRoute?.settings.arguments;

    if (oldRouteName != null && oldRouteArguments is Map<String, dynamic>) {
      log('didReplace ${oldRouteName} ${oldRouteArguments}');
      _analyticsRepository.logPageClose(
        oldRouteName,
        oldRouteArguments,
      );
    }

    final routeName = newRoute?.settings.name;
    final routeArguments = newRoute?.settings.arguments;

    if (routeName != null && routeArguments is Map<String, dynamic>) {
      log('didReplace ${routeName} ${routeArguments}');
      _analyticsRepository.logPageClose(
        routeName,
        routeArguments,
      );
    }
  }
}

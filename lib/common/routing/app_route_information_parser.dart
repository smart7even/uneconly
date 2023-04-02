import 'package:flutter/material.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/constants.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final location = routeInformation.location;

    if (location == null) {
      // TODO: redirect to home page
      return const AppRoutePath.schedule(
        groupId: pi2002groupId,
      );
    }

    final uri = Uri.parse(location);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      // TODO: redirect to home page
      return const AppRoutePath.schedule(
        groupId: pi2002groupId,
      );
    }

    // Handle '/schedule/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'schedule') {
        // TODO: redirect to page not found page
        return const AppRoutePath.schedule(groupId: pi2002groupId);
      }

      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) {
        // TODO: redirect to unknown group page
        return const AppRoutePath.schedule(groupId: pi2002groupId);
      }

      return AppRoutePath.schedule(groupId: id);
    }

    // Handle unknown routes
    // TODO: redirect to page not found page
    return const AppRoutePath.schedule(groupId: pi2002groupId);
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return configuration.map(schedule: (configuration) {
      return RouteInformation(location: 'schedule/${configuration.groupId}');
    });
  }
}

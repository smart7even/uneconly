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

    // Handle '/group/:id/schedule/'
    if (uri.pathSegments.length == 3) {
      if (uri.pathSegments[0] != 'group') {
        // TODO: redirect to page not found page
        return const AppRoutePath.schedule(groupId: pi2002groupId);
      }

      var groupIdPath = uri.pathSegments[1];
      var id = int.tryParse(groupIdPath);

      if (id == null) {
        // TODO: redirect to no id specified page
        return const AppRoutePath.schedule(groupId: pi2002groupId);
      }

      if (uri.pathSegments[2] != 'schedule') {
        // TODO: redirect to page not found page
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
      return RouteInformation(
        location: '/group/${configuration.groupId}/schedule',
      );
    });
  }
}

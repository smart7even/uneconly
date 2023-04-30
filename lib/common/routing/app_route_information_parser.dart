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
      return const AppRoutePath.select();
    }

    final uri = Uri.parse(location);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.select();
    }

    // Handle '/group/:id/schedule/'
    if (uri.pathSegments.length == 3) {
      if (uri.pathSegments[0] != 'group') {
        return const AppRoutePath.select();
      }

      var groupIdPath = uri.pathSegments[1];
      var id = int.tryParse(groupIdPath);

      if (id == null) {
        // TODO: redirect to no id specified page
        return const AppRoutePath.schedule(
          groupId: pi2002groupId,
          groupName: pi2002groupName,
        );
      }

      if (uri.pathSegments[2] != 'schedule') {
        // TODO: redirect to page not found page
        return const AppRoutePath.schedule(
          groupId: pi2002groupId,
          groupName: pi2002groupName,
        );
      }

      return AppRoutePath.schedule(
        groupId: id,
        groupName: pi2002groupName,
      );
    }

    // Handle unknown routes
    // TODO: redirect to page not found page
    return const AppRoutePath.schedule(
      groupId: pi2002groupId,
      groupName: pi2002groupName,
    );
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return configuration.map(
      schedule: (configuration) {
        return RouteInformation(
          location: '/group/${configuration.groupId}/schedule',
          state: configuration.toJson(),
        );
      },
      select: (_) {
        return RouteInformation(
          location: '/',
          state: const AppRoutePath.select().toJson(),
        );
      },
    );
  }
}

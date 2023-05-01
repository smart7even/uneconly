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
      return const AppRoutePath.loading();
    }

    final uri = Uri.parse(location);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.loading();
    }

    // Handle '/select'
    if (uri.pathSegments[0] == 'select') {
      return const AppRoutePath.select();
    }

    // Handle '/group/:id/schedule/'
    if (uri.pathSegments.length == 3) {
      if (uri.pathSegments[0] != 'group') {
        return const AppRoutePath.loading();
      }

      var groupIdPath = uri.pathSegments[1];
      var id = int.tryParse(groupIdPath);
      var name = uri.queryParameters['name'];

      if (id == null) {
        return const AppRoutePath.select();
      }

      if (uri.pathSegments[2] != 'schedule' || name == null) {
        return const AppRoutePath.select();
      }

      return AppRoutePath.schedule(
        groupId: id,
        groupName: name,
      );
    }

    // Handle unknown routes
    return const AppRoutePath.select();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return configuration.map(
      loading: (configuration) {
        return RouteInformation(
          location: '/',
          state: configuration.toJson(),
        );
      },
      schedule: (configuration) {
        return RouteInformation(
          location:
              '/group/${configuration.groupId}/schedule?name=${configuration.groupName}',
          state: configuration.toJson(),
        );
      },
      select: (_) {
        return RouteInformation(
          location: '/select',
          state: const AppRoutePath.select().toJson(),
        );
      },
    );
  }
}

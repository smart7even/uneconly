import 'package:flutter/material.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.loading();
    }

    // Handle '/select'
    if (uri.pathSegments[0] == 'select') {
      return const AppRoutePath.select();
    }

    // Handle '/settings'
    if (uri.pathSegments[0] == 'settings') {
      return const AppRoutePath.settings();
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

      if (uri.pathSegments[2] != 'schedule') {
        return const AppRoutePath.select();
      }

      return AppRoutePath.schedule(
        shortGroupInfo: ShortGroupInfo(
          groupId: id,
          groupName: name,
        ),
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
          uri: Uri.parse('/'),
          state: configuration.toJson(),
        );
      },
      schedule: (configuration) {
        return RouteInformation(
          uri: Uri.parse(
            '/group/${configuration.shortGroupInfo.groupId}/schedule?name=${configuration.shortGroupInfo.groupName}',
          ),
          state: configuration.toJson(),
        );
      },
      select: (configuration) {
        return RouteInformation(
          uri: Uri.parse('/select'),
          state: configuration.toJson(),
        );
      },
      settings: (configuration) {
        return RouteInformation(
          uri: Uri.parse('/settings'),
          state: configuration.toJson(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
import 'package:uneconly/common/routing/navigation_observer.dart';
import 'package:uneconly/feature/loading/widget/loading_page.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';
import 'package:uneconly/feature/settings/widget/settings_page.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        pageObserver = PageObserver(),
        modalObserver = ModalObserver();

  final PageObserver pageObserver;
  final ModalObserver modalObserver;

  AppRoutePath currentPath = const AppRoutePath.loading();

  void handleSchedulePageOpened(int groupId, String groupName) {
    currentPath = AppRoutePath.schedule(
      shortGroupInfo: ShortGroupInfo(
        groupId: groupId,
        groupName: groupName,
      ),
    );
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    AppRoutePath path = currentPath;

    return AppRouter(
      routerDelegate: this,
      child: Navigator(
        key: navigatorKey,
        pages: path.map(
          loading: (value) {
            return [
              const MaterialPage(
                key: ValueKey('LoadingPage'),
                child: LoadingPage(),
              ),
            ];
          },
          schedule: (path) {
            return [
              MaterialPage(
                key: const ValueKey('SchedulePage'),
                child: SchedulePage(
                  shortGroupInfo: ShortGroupInfo(
                    groupId: path.shortGroupInfo.groupId,
                    groupName: path.shortGroupInfo.groupName,
                  ),
                ),
              ),
            ];
          },
          select: (path) {
            final shortGroupInfo = path.shortGroupInfo;

            return [
              if (shortGroupInfo != null)
                MaterialPage(
                  key: const ValueKey('SchedulePage'),
                  child: SchedulePage(
                    shortGroupInfo: ShortGroupInfo(
                      groupId: shortGroupInfo.groupId,
                      groupName: shortGroupInfo.groupName,
                    ),
                  ),
                ),
              const MaterialPage(
                key: ValueKey('SelectPage'),
                child: SelectPage(),
              ),
            ];
          },
          settings: (SettingsAppRoutePath path) {
            final shortGroupInfo = path.shortGroupInfo;

            return [
              MaterialPage(
                key: const ValueKey('SchedulePage'),
                child: SchedulePage(
                  shortGroupInfo: ShortGroupInfo(
                    groupId: shortGroupInfo.groupId,
                    groupName: shortGroupInfo.groupName,
                  ),
                ),
              ),
              const MaterialPage(
                key: ValueKey('SettingsPage'),
                child: SettingsPage(),
              ),
            ];
          },
        ),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          currentPath.mapOrNull(
            select: (value) {
              var shortGroupInfo = value.shortGroupInfo;
              if (shortGroupInfo != null) {
                currentPath = AppRoutePath.schedule(
                  shortGroupInfo: shortGroupInfo,
                );
              }
            },
            settings: (value) {
              var shortGroupInfo = value.shortGroupInfo;
              currentPath = AppRoutePath.schedule(
                shortGroupInfo: shortGroupInfo,
              );
            },
          );

          notifyListeners();

          return true;
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    currentPath = configuration;
    notifyListeners();
  }

  @override
  AppRoutePath get currentConfiguration {
    return currentPath;
  }
}

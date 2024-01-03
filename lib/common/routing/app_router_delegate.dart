import 'package:collection/collection.dart';
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

  final List<AppRoutePath> _history = [];
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
                child: LoadingPage(
                  isActive: true,
                ),
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
            AppRoutePath? previousPath;

            if (_history.isNotEmpty) {
              previousPath = _history.lastWhereOrNull(
                (element) => element is ScheduleAppRoutePath,
              );
            } else {
              previousPath = null;
            }

            if (previousPath is ScheduleAppRoutePath) {
              return [
                MaterialPage(
                  key: const ValueKey('SchedulePage'),
                  child: SchedulePage(
                    shortGroupInfo: ShortGroupInfo(
                      groupId: previousPath.shortGroupInfo.groupId,
                      groupName: previousPath.shortGroupInfo.groupName,
                    ),
                  ),
                ),
                const MaterialPage(
                  key: ValueKey('SettingsPage'),
                  child: SettingsPage(),
                ),
              ];
            }

            return [
              const MaterialPage(
                key: ValueKey('LoadingPage'),
                child: LoadingPage(
                  isActive: false,
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
              AppRoutePath? previousPath;

              if (_history.isNotEmpty) {
                previousPath = _history.lastWhereOrNull(
                  (element) => element is ScheduleAppRoutePath,
                );
              } else {
                previousPath = null;
              }

              if (previousPath is ScheduleAppRoutePath) {
                currentPath = AppRoutePath.schedule(
                  shortGroupInfo: ShortGroupInfo(
                    groupId: previousPath.shortGroupInfo.groupId,
                    groupName: previousPath.shortGroupInfo.groupName,
                  ),
                );
              } else {
                currentPath = const AppRoutePath.loading();
              }
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
    _history.add(configuration);
    notifyListeners();
  }

  @override
  AppRoutePath get currentConfiguration {
    return currentPath;
  }
}

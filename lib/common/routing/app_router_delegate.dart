import 'package:flutter/material.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
import 'package:uneconly/common/routing/navigation_observer.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';

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

  AppRoutePath currentPath =
      const AppRoutePath.schedule(groupId: pi2002groupId);

  void handleSchedulePageOpened(int groupId) {
    currentPath = AppRoutePath.schedule(groupId: groupId);
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    AppRoutePath path = currentPath;

    return AppRouter(
      routerDelegate: this,
      child: Navigator(
        pages: path.map(
          schedule: (path) {
            return [
              const MaterialPage(
                key: ValueKey('SchedulePage'),
                child: SchedulePage(),
              ),
            ];
          },
          select: (path) {
            return [
              const MaterialPage(
                key: ValueKey('SelectPage'),
                child: SelectPage(),
              ),
            ];
          },
        ),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

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

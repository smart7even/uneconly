import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

enum HomeTabsEnum implements Comparable<HomeTabsEnum> {
  schedule,
  vacancies;

  static HomeTabsEnum fromValue(String? value, {HomeTabsEnum? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        'schedule' => schedule,
        'vacancies' => vacancies,
        _ => fallback ?? (throw ArgumentError.value(value)),
      };

  @override
  int compareTo(HomeTabsEnum other) => index.compareTo(other.index);

  @override
  String toString() => name;
}

/// {@template home_page}
/// HomePage widget
/// {@endtemplate}
class HomePage extends StatefulWidget {
  /// {@macro home_page}
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
} // HomePage

/// State for widget HomePage
class _HomePageState extends State<HomePage> {
  HomeTabsEnum _tab = HomeTabsEnum.schedule;
  late final OctopusStateObserver _octopusStateObserver;

  Group? myGroup;

  bool bottomBarEnabled = false;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    onOpen();

    _octopusStateObserver = context.octopus.observer;

    // Restore tab from router arguments
    _tab = HomeTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['page'],
      fallback: HomeTabsEnum.schedule,
    );
    _octopusStateObserver.addListener(_onOctopusStateChanged);
  }

  // Router state changed
  void _onOctopusStateChanged() {
    final newTab = HomeTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['page'],
      fallback: HomeTabsEnum.schedule,
    );
    _switchTab(newTab);
  }

  // Change tab
  void _switchTab(HomeTabsEnum tab) {
    if (!mounted) return;
    if (_tab == tab) return;
    context.octopus.setArguments((args) => args['page'] = tab.name);
    setState(() => _tab = tab);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  Future<void> onOpen() async {
    ISettingsRepository settingsRepository =
        Dependencies.of(context).settingsRepository;

    final group = await settingsRepository.getGroup();

    if (!mounted) {
      return;
    }

    if (group == null) {
      Octopus.of(context).setState((state) {
        return state
          ..removeWhere((node) => true)
          ..add(
            Routes.select.node(),
          );
      });
    } else {
      HomeWidget.saveWidgetData<int>(
        'groupId',
        group.id,
      ).then((value) {
        HomeWidget.updateWidget(
          name: 'UWidget',
          iOSName: 'UWidget',
        );
      });

      setState(() {
        myGroup = group;
      });
    }
  }

  // Bottom navigation bar item tapped
  void _onItemTapped(int index) {
    final newTab = HomeTabsEnum.values[index];
    if (_tab == newTab) {
      // The same tab tapped twice
      return;
    } else {
      // Switch tab to new one
      _switchTab(newTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMyGroup = myGroup;

    if (currentMyGroup == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: bottomBarEnabled
          ? BottomNavigationBar(
              elevation: 0,
              currentIndex: _tab.index,
              onTap: _onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.today),
                //   label: 'Daily',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work),
                  label: 'Vacancies',
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _tab.index,
        children: [
          SchedulePage(
            scheduleInfo: ScheduleInfo.group(
              shortGroupInfo: ShortGroupInfo(
                groupId: currentMyGroup.id,
                groupName: currentMyGroup.name,
              ),
            ),
            isViewMode: false,
          ),
          Scaffold(
            appBar: AppBar(
              title: const Text('Vacancies'),
            ),
            body: const Center(
              child: Text('Vacancies'),
            ),
          ),
        ],
      ),
    );
  }
} // _HomePageState

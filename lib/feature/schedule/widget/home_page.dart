import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

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
  Group? myGroup;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    onOpen();
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

    return SchedulePage(
      shortGroupInfo: ShortGroupInfo(
        groupId: currentMyGroup.id,
        groupName: currentMyGroup.name,
      ),
      isViewMode: false,
    );
  }
} // _HomePageState

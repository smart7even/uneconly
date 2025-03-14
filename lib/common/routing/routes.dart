import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';
import 'package:uneconly/feature/loading/widget/loading_page.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/home_page.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';
import 'package:uneconly/feature/settings/widget/settings_page.dart';
import 'package:uneconly/feature/tutorials/widget/home_widget_tutorial.dart';
import 'package:uneconly/feature/tutorials/widget/tutorials_page.dart';

enum Routes with OctopusRoute {
  loading('loading', title: 'Loading'),
  schedule('schedule', title: 'Schedule'),
  select('select', title: 'Select'),
  settings('settings', title: 'Settings'),
  home('home', title: 'Home'),
  tutorials('tutorials', title: 'Tutorials'),
  homeWidgetTutorial('homeWidgetTutorial', title: 'Home Widget Tutorial');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) {
    switch (this) {
      case Routes.loading:
        return const LoadingPage(
          isActive: true,
        );
      case Routes.schedule:
        final isGroup = node.arguments['groupId'] != null;

        if (isGroup) {
          return SchedulePage(
            scheduleInfo: ScheduleInfo.group(
              shortGroupInfo: ShortGroupInfo(
                groupId: int.parse(node.arguments['groupId'] as String),
                groupName: node.arguments['groupName'] as String,
              ),
            ),
            isViewMode: node.arguments['isViewMode'] != null
                ? node.arguments['isViewMode'] as String == 'true'
                : true,
          );
        } else {
          return SchedulePage(
            scheduleInfo: ScheduleInfo.professor(
              shortProfessorInfo: ShortProfessorInfo(
                professorId: int.parse(node.arguments['professorId'] as String),
                professorName: node.arguments['professorName'] as String,
              ),
            ),
            isViewMode: node.arguments['isViewMode'] != null
                ? node.arguments['isViewMode'] as String == 'true'
                : true,
          );
        }

      case Routes.select:
        return SelectPage(
          mode: node.arguments['mode'] != null
              ? SelectPageMode.fromName(node.arguments['mode'] as String)
              : SelectPageMode.select,
        );
      case Routes.settings:
        return const SettingsPage();
      case Routes.home:
        return const HomePage();
      case Routes.tutorials:
        return const TutorialsPage();
      case Routes.homeWidgetTutorial:
        return const HomeWidgetTutorial();
    }
  }
}

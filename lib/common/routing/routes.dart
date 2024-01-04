import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/loading/widget/loading_page.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';
import 'package:uneconly/feature/settings/widget/settings_page.dart';

enum Routes with OctopusRoute {
  loading('loading', title: 'Loading'),
  schedule('schedule', title: 'Schedule'),
  select('select', title: 'Select'),
  settings('settings', title: 'Settings');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusNode node) {
    switch (this) {
      case Routes.loading:
        return const LoadingPage(
          isActive: true,
        );
      case Routes.schedule:
        return SchedulePage(
          shortGroupInfo: ShortGroupInfo(
            groupId: int.parse(node.arguments['groupId'] as String),
            groupName: node.arguments['groupName'] as String,
          ),
          isViewMode: node.arguments['isViewMode'] != null
              ? node.arguments['isViewMode'] as String == 'true'
              : false,
        );
      case Routes.select:
        return SelectPage(
          mode: node.arguments['mode'] != null
              ? SelectPageMode.fromName(node.arguments['mode'] as String)
              : SelectPageMode.select,
        );
      case Routes.settings:
        return const SettingsPage();
    }
  }
}

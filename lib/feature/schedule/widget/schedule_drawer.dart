import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/pubspec.yaml.g.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';

class ScheduleDrawer extends StatelessWidget {
  const ScheduleDrawer({
    super.key,
    required this.favoriteGroups,
    required this.onFavoriteGroupsRefresh,
  });

  final List<Group> favoriteGroups;
  final VoidCallback onFavoriteGroupsRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBLoC, ScheduleState>(
      builder: (context, state) => Drawer(
        semanticLabel: context.string.options,
        backgroundColor: context.palette.surface,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.string.selectedGroup.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.palette.muted,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        state.scheduleInfo?.title ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text('Моё расписание'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.octopus.push(Routes.select),
                    ),
                    const SizedBox(height: 14),
                    _DrawerRow(
                      icon: Icons.search,
                      title: context.string.viewScheduleOfAnotherGroup,
                      onTap: () => _openOtherGroup(context),
                    ),
                    _DrawerRow(
                      icon: Icons.newspaper_outlined,
                      title: 'Новости и ссылки',
                      onTap: () => context.octopus.push(Routes.tutorials),
                    ),
                    _DrawerRow(
                      icon: Icons.settings_outlined,
                      title: context.string.settings,
                      onTap: () => context.octopus.push(Routes.settings),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.string.favoriteGroups.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.palette.muted,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                    if (favoriteGroups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: Text(
                          'Здесь появятся группы, расписание которых вы смотрите часто.',
                          style: TextStyle(color: context.palette.muted),
                        ),
                      )
                    else
                      for (final group in favoriteGroups)
                        ListTile(
                          leading: Icon(Icons.star_outline,
                              color: context.palette.accent),
                          title: Text(group.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openFavorite(context, group),
                        ),
                    TextButton.icon(
                      onPressed: () => _addFavorite(context),
                      icon: const Icon(Icons.add),
                      label: Text(context.string.add),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Uneconly ${Pubspec.version.representation}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.muted,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openOtherGroup(BuildContext context) async {
    final octopus = context.octopus;
    await octopus.push(Routes.select, arguments: {'mode': 'view'});
    await waitReturnToHomeSchedule(octopus);
    onFavoriteGroupsRefresh();
  }

  Future<void> _openFavorite(BuildContext context, Group group) async {
    final octopus = context.octopus;
    await octopus.push(
      Routes.schedule,
      arguments: {
        'groupId': group.id.toString(),
        'groupName': group.name,
        'isViewMode': 'true',
      },
    );
    await waitReturnToHomeSchedule(octopus);
    onFavoriteGroupsRefresh();
  }

  Future<void> _addFavorite(BuildContext context) async {
    final octopus = context.octopus;
    await octopus.push(
      Routes.select,
      arguments: {'mode': SelectPageMode.favorite.name},
    );
    await waitReturnToHomeSchedule(octopus);
    onFavoriteGroupsRefresh();
  }
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      );
}

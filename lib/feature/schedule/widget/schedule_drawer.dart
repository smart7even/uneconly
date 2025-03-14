import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';

/// {@template home_drawer}
/// HomeDrawer widget
/// {@endtemplate}
class ScheduleDrawer extends StatelessWidget {
  final List<Group> favoriteGroups;
  final VoidCallback onFavoriteGroupsRefresh;

  /// {@macro home_drawer}
  const ScheduleDrawer({
    super.key,
    required this.favoriteGroups,
    required this.onFavoriteGroupsRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBLoC, ScheduleState>(
      builder: (context, state) {
        return Drawer(
          semanticLabel: AppLocalizations.of(context)!.options,
          child: ListView(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectedGroup,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.scheduleInfo?.title ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.selectAnotherGroup,
                ),
                onTap: () {
                  Octopus.of(context).push(
                    Routes.select,
                  );
                },
              ),
              // ListTile for settings
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.settings,
                ),
                onTap: () {
                  Octopus.of(
                    context,
                  ).push(
                    Routes.settings,
                  );
                },
              ),
              // ListTile for news
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.news,
                ),
                onTap: () {
                  Octopus.of(
                    context,
                  ).push(
                    Routes.tutorials,
                  );
                },
              ),
              // ListTile to view schedule of another group
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.viewScheduleOfAnotherGroup,
                ),
                onTap: () async {
                  final octopus = context.octopus;

                  await octopus.push(
                    Routes.select,
                    arguments: {
                      'mode': 'view',
                    },
                  );

                  await waitReturnToHomeSchedule(
                    octopus,
                  );

                  onFavoriteGroupsRefresh();
                },
              ),
              // Title for lisview of favorite groups
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.favoriteGroups,
                  // heading style
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // If there are no favorite groups show button to add one
              if (favoriteGroups.isEmpty)
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.addFirstFavoriteGroup,
                  ),
                ),

              // Listview to view favorite groups
              if (favoriteGroups.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoriteGroups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        favoriteGroups[index].name,
                      ),
                      onTap: () async {
                        final octopus = context.octopus;

                        await octopus.push(
                          Routes.schedule,
                          arguments: {
                            'groupId': favoriteGroups[index].id.toString(),
                            'groupName': favoriteGroups[index].name,
                            'isViewMode': 'true',
                          },
                        );

                        await waitReturnToHomeSchedule(octopus);

                        onFavoriteGroupsRefresh();
                      },
                    );
                  },
                ),
              // Elevated Button with minimum possible width to add favorite group
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 132,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final octopus = context.octopus;

                      await octopus.push(
                        Routes.select,
                        arguments: {
                          'mode': SelectPageMode.favorite.name,
                        },
                      );

                      await waitReturnToHomeSchedule(octopus);

                      onFavoriteGroupsRefresh();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} // HomeDrawer

import 'dart:async';
import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l/l.dart';
import 'package:octopus/octopus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/routing/routing_utils.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/widget/schedule_widget.dart';
import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/select/widget/select_page.dart';

/// {@template schedule_page}
/// SchedulePage widget
/// {@endtemplate}
class SchedulePage extends StatefulWidget {
  final ShortGroupInfo shortGroupInfo;
  final bool isViewMode;

  /// {@macro schedule_page}
  const SchedulePage({
    super.key,
    required this.shortGroupInfo,
    required this.isViewMode,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
} // SchedulePage

/// State for widget SchedulePage
class _SchedulePageState extends State<SchedulePage>
    with WidgetsBindingObserver {
  static const initialPageIndex = 4242;

  final controller = PageController(
    initialPage: initialPageIndex,
  );

  late final ScheduleBLoC scheduleBLoC;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Group> favoriteGroups = [];
  bool isFavorite = false;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en');
    // Initial state initialization

    scheduleBLoC = _initBloc(context);

    WidgetsBinding.instance.addObserver(this);

    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request permissions for calendar

    var calendarWriteOnlyStatus = await Permission.calendarWriteOnly.request();
    l.v6(calendarWriteOnlyStatus);
    var calendarStatus = await Permission.calendarFullAccess.request();
    l.v6(calendarStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dependenciesScope = Dependencies.of(context);

    dependenciesScope.settingsRepository.getFavoriteGroups().then(
      (value) {
        setState(() {
          favoriteGroups.clear();
          favoriteGroups.addAll(value);

          if (favoriteGroups.any(
            (element) => element.id == widget.shortGroupInfo.groupId,
          )) {
            setState(() {
              isFavorite = true;
            });
          }
        });
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Called when the application state changes

    if (state == AppLifecycleState.resumed) {
      scheduleBLoC.add(
        ScheduleEvent.fetch(
          groupId: widget.shortGroupInfo.groupId,
          week: scheduleBLoC.state.selectedWeek ?? _getCurrentWeek(),
        ),
      );

      setState(() {
        log('app resumed');
      });
    }
  }

  int _getCurrentWeek() {
    final currentTime = DateTime.now();

    return getStudyWeekNumber(currentTime, currentTime);
  }

  ScheduleBLoC _initBloc(BuildContext context) {
    final dependenciesScope = Dependencies.of(context);

    ScheduleNetworkDataProvider scheduleNetworkDataProvider =
        ScheduleNetworkDataProvider(
      dio: dependenciesScope.dio,
    );

    IScheduleLocalDataProvider localDataProvider = ScheduleLocalDataProvider(
      dependenciesScope.database,
    );

    IScheduleRepository repository = ScheduleRepository(
      networkDataProvider: scheduleNetworkDataProvider,
      localDataProvider: localDataProvider,
    );

    IGroupNetworkDataProvider groupNetworkDataProvider =
        GroupNetworkDataProvider(
      dio: dependenciesScope.dio,
    );

    IGroupRepository groupRepository = GroupRepository(
      networkDataProvider: groupNetworkDataProvider,
    );

    var bloc = ScheduleBLoC(
      repository: repository,
      groupRepository: groupRepository,
    );

    bloc.add(
      ScheduleEvent.fetch(
        groupId: widget.shortGroupInfo.groupId,
        week: _getCurrentWeek(),
        shortGroupInfo: widget.shortGroupInfo,
      ),
    );

    return bloc;
  }

  @override
  void didUpdateWidget(SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shortGroupInfo != oldWidget.shortGroupInfo) {
      scheduleBLoC.add(
        ScheduleEvent.changeGroup(
          groupId: widget.shortGroupInfo.groupId,
          week: scheduleBLoC.state.selectedWeek ?? _getCurrentWeek(),
          shortGroupInfo: widget.shortGroupInfo,
        ),
      );

      final scaffoldState = _scaffoldKey.currentState;

      if (scaffoldState == null) {
        return;
      }

      if (scaffoldState.isDrawerOpen) {
        scaffoldState.closeDrawer();
      }
    }
  }

  Future<void> onPageChanged(
    BuildContext context,
    int newIndex,
    int? week,
  ) async {
    if (week == null) {
      return;
    }

    int newWeek = week + newIndex - initialPageIndex;

    context.read<ScheduleBLoC>().add(
          ScheduleEvent.fetch(
            groupId: widget.shortGroupInfo.groupId,
            week: newWeek,
          ),
        );

    context.octopus.setArguments(
      (args) {
        args['week'] = newWeek.toString();
      },
    );
  }

  Future<void> waitReturnToSchedule(
    Octopus octopus,
  ) async {
    await waitRouteChange(
      octopus,
      shouldStopListen: () {
        final lastNode = octopus.observer.value.children.last;

        return lastNode.name == Routes.schedule.name &&
            lastNode.arguments['groupId'] ==
                widget.shortGroupInfo.groupId.toString();
      },
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    ScheduleState state,
  ) {
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
                  state.shortGroupInfo?.groupName ?? '',
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
          // ListTile to view schedule of another group
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.viewScheduleOfAnotherGroup,
            ),
            onTap: () async {
              final dependenciesScope = Dependencies.of(context);

              final octopus = context.octopus;

              await octopus.push(
                Routes.select,
                arguments: {
                  'mode': 'view',
                },
              );

              await waitReturnToSchedule(
                octopus,
              );

              final value = await dependenciesScope.settingsRepository
                  .getFavoriteGroups();

              setState(() {
                favoriteGroups.clear();
                favoriteGroups.addAll(value);
              });
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
                    final dependenciesScope = Dependencies.of(context);

                    await octopus.push(
                      Routes.schedule,
                      arguments: {
                        'groupId': favoriteGroups[index].id.toString(),
                        'groupName': favoriteGroups[index].name,
                        'isViewMode': 'true',
                      },
                    );

                    await waitReturnToSchedule(octopus);

                    final value = await dependenciesScope.settingsRepository
                        .getFavoriteGroups();

                    setState(() {
                      favoriteGroups.clear();
                      favoriteGroups.addAll(value);
                    });
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
                  final dependenciesScope = Dependencies.of(context);

                  final octopus = context.octopus;

                  await octopus.push(
                    Routes.select,
                    arguments: {
                      'mode': SelectPageMode.favorite.name,
                    },
                  );

                  await waitReturnToSchedule(octopus);

                  final value = await dependenciesScope.settingsRepository
                      .getFavoriteGroups();

                  setState(() {
                    favoriteGroups.clear();
                    favoriteGroups.addAll(value);
                  });
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
  }

  void onNextWeek(BuildContext context) {
    final currentPage = controller.page;
    final week = scheduleBLoC.state.currentWeek;

    if (currentPage == null) {
      return;
    }

    final newPage = currentPage + 1;

    controller.animateToPage(
      newPage.round(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );

    onPageChanged(context, newPage.round(), week);
  }

  void onPreviousWeek(BuildContext context) {
    final currentPage = controller.page;
    final week = scheduleBLoC.state.currentWeek;

    if (currentPage == null) {
      return;
    }

    final newPage = currentPage - 1;

    controller.animateToPage(
      newPage.round(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );

    onPageChanged(context, newPage.round(), week);
  }

  Widget _buildPageView(
    BuildContext context,
    ScheduleState state,
  ) {
    int? week = state.currentWeek;
    int? selectedWeek = state.selectedWeek;
    Map<int, ScheduleDetails> data = state.data;
    String message = state.message;

    if (week == 0) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(
          context,
          state,
        ),
        appBar: AppBar(
          title: Text(state.shortGroupInfo?.groupName ?? ''),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    }

    String title = state.shortGroupInfo?.groupName ?? '';

    if (selectedWeek != null) {
      title += ', ${AppLocalizations.of(context)!.week} $selectedWeek';

      if (week != null && week == selectedWeek) {
        title += ' (${AppLocalizations.of(context)!.now})';
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: !widget.isViewMode
          ? _buildDrawer(
              context,
              state,
            )
          : null,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.isViewMode)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });

                  if (isFavorite) {
                    Dependencies.of(context)
                        .settingsRepository
                        .addGroupToFavorites(
                          Group(
                            id: state.shortGroupInfo?.groupId ??
                                widget.shortGroupInfo.groupId,
                            name: state.shortGroupInfo?.groupName ??
                                widget.shortGroupInfo.groupName ??
                                '',
                            facultyId: 0,
                            course: 0,
                          ),
                        );
                  } else {
                    Dependencies.of(context)
                        .settingsRepository
                        .removeGroupFromFavorites(
                          Group(
                            id: state.shortGroupInfo?.groupId ??
                                widget.shortGroupInfo.groupId,
                            name: state.shortGroupInfo?.groupName ??
                                widget.shortGroupInfo.groupName ??
                                '',
                            facultyId: 0,
                            course: 0,
                          ),
                        );
                  }
                },
                tooltip: isFavorite
                    ? AppLocalizations.of(context)!.removeFromFavorites
                    : AppLocalizations.of(context)!.addToFavorites,
                icon: isFavorite
                    ? const Icon(Icons.star)
                    : const Icon(
                        Icons.star_outline,
                      ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (int newIndex) => onPageChanged(context, newIndex, week),
        itemBuilder: (context, index) {
          int? currentWeek;

          if (week != null) {
            currentWeek = week + index - initialPageIndex;
          }

          if (currentWeek == null) {
            return ScheduleWidget(
              schedule: const Schedule.empty(),
              onNextWeek: () => onNextWeek(context),
              onPreviousWeek: () => onPreviousWeek(context),
            );
          }

          if (currentWeek < 0 || currentWeek > 52) {
            return ScheduleWidget(
              schedule: const Schedule.empty(),
              onNextWeek: () => onNextWeek(context),
              onPreviousWeek: () => onPreviousWeek(context),
            );
          }

          return ScheduleWidget(
            schedule: data[currentWeek]?.schedule,
            onNextWeek: () => onNextWeek(context),
            onPreviousWeek: () => onPreviousWeek(context),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: scheduleBLoC,
      child: BlocBuilder<ScheduleBLoC, ScheduleState>(
        builder: (context, state) {
          return state.map<Widget>(
            idle: (state) => _buildPageView(
              context,
              state,
            ),
            processing: (state) => _buildPageView(
              context,
              state,
            ),
            successful: (state) => _buildPageView(
              context,
              state,
            ),
            error: (state) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    AppLocalizations.of(context)!.scheduleError,
                  ),
                ),
                body: Center(
                  child: Text(
                    AppLocalizations.of(context)!.schedule,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} // _SchedulePageState

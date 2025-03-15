import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:octopus/octopus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/routing/routing_utils.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_actions_popup.dart';
import 'package:uneconly/feature/schedule/widget/schedule_drawer.dart';
import 'package:uneconly/feature/schedule/widget/schedule_widget.dart';
import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/group.dart';

/// {@template schedule_page}
/// SchedulePage widget
/// {@endtemplate}
class SchedulePage extends StatefulWidget {
  final ScheduleInfo scheduleInfo;
  final bool isViewMode;

  /// {@macro schedule_page}
  const SchedulePage({
    super.key,
    required this.scheduleInfo,
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

  Timer? _rebuildTimer;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en');
    // Initial state initialization

    log(Octopus.of(context).state.uri.toString());

    scheduleBLoC = _initBloc(context);

    WidgetsBinding.instance.addObserver(this);

    final dependenciesScope = Dependencies.of(context);

    dependenciesScope.settingsRepository.getFavoriteGroups().then(
      (value) {
        setState(() {
          widget.scheduleInfo.map(
            group: (group) {
              favoriteGroups.clear();
              favoriteGroups.addAll(value);

              if (favoriteGroups.any(
                (element) => element.id == group.shortGroupInfo.groupId,
              )) {
                setState(() {
                  isFavorite = true;
                });
              }
            },
            professor: (professor) {
              // TODO: add favorite professors
              return;
            },
          );
        });
      },
    );

    _rebuildTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        if (context.mounted) {
          setState(() {
            log('rebuild');
          });
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rebuildTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Called when the application state changes

    if (state == AppLifecycleState.resumed) {
      scheduleBLoC.add(
        ScheduleEvent.fetch(
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
        week: _getCurrentWeek(),
        info: widget.scheduleInfo,
      ),
    );

    return bloc;
  }

  @override
  void didUpdateWidget(SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scheduleInfo != oldWidget.scheduleInfo) {
      scheduleBLoC.add(
        ScheduleEvent.changeGroup(
          week: scheduleBLoC.state.selectedWeek ?? _getCurrentWeek(),
          info: widget.scheduleInfo,
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
            info: widget.scheduleInfo,
            week: newWeek,
          ),
        );

    context.octopus.setArguments(
      (args) {
        args['week'] = newWeek.toString();
      },
    );
  }

  Future<void> _onFavoriteGroupsRefresh() async {
    final dependencies = Dependencies.of(context);

    final value = await dependencies.settingsRepository.getFavoriteGroups();

    setState(() {
      favoriteGroups.clear();
      favoriteGroups.addAll(value);
    });
  }

  Widget _buildDrawer(
    BuildContext context,
    ScheduleState state,
  ) {
    return ScheduleDrawer(
      favoriteGroups: favoriteGroups,
      onFavoriteGroupsRefresh: _onFavoriteGroupsRefresh,
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

  void onFavoritePressed(
    BuildContext context,
    ScheduleState state,
  ) {
    setState(() {
      isFavorite = !isFavorite;
    });

    state.scheduleInfo?.map(
      group: (group) {
        final groupModel = Group(
          id: group.shortGroupInfo.groupId,
          name: group.shortGroupInfo.groupName ?? '',
          facultyId: 0,
          course: 0,
        );

        if (isFavorite) {
          Dependencies.of(context).settingsRepository.addGroupToFavorites(
                groupModel,
              );
        } else {
          Dependencies.of(context).settingsRepository.removeGroupFromFavorites(
                groupModel,
              );
        }
      },
      professor: (professor) {
        // TODO: add favorite professors
        return;
      },
    );
  }

  void onSharePressed(BuildContext context, ScheduleState state) {
    final bloc = context.read<ScheduleBLoC>();

    bloc.add(
      ScheduleEvent.share(
        (content) async {
          await Share.share(content);

          // final groupInfo = state.shortGroupInfo;

          // if (groupInfo == null) {
          //   return;
          // }

          // final groupName = groupInfo.groupName;

          // if (groupName == null) {
          //   return;
          // }

          // final navigationState = OctopusState.fromNodes([
          //   Routes.home.node(),
          //   Routes.schedule.node(
          //     arguments: <String, String>{
          //       'groupId': groupInfo.groupId.toString(),
          //       'groupName': groupName,
          //     },
          //   ),
          // ]);

          // print(navigationState.location);

          // await Share.shareUri(Uri.parse(
          //   'https://roadmapik.com${navigationState.location}',
          // ));

          // await showDialog(
          //   context: context,
          //   builder: (context) {
          //     return Material(
          //       child: GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).pop();
          //         },
          //         child: SingleChildScrollView(child: Text(content)),
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
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
          title: Text(state.scheduleInfo?.title ?? ''),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    }

    String title = state.scheduleInfo?.title ?? '';

    if (selectedWeek != null) {
      title += ', ${AppLocalizations.of(context)!.week} $selectedWeek';

      if (week != null && week == selectedWeek) {
        title += ' (${AppLocalizations.of(context)!.now})';
      }
    }

    final isGroupSchedule = widget.scheduleInfo.map(
      group: (group) => true,
      professor: (professor) => false,
    );

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
        centerTitle: true,
        actions: [
          ScheduleActionsPopup(
            actions: [
              if (widget.isViewMode && isGroupSchedule)
                ScheduleActionConfig(
                  Text(
                    isFavorite
                        ? AppLocalizations.of(context)!.removeFromFavorites
                        : AppLocalizations.of(context)!.addToFavorites,
                  ),
                  action: ScheduleAction.favorite,
                  onPressed: () => onFavoritePressed(context, state),
                ),
              ScheduleActionConfig(
                Text(
                  AppLocalizations.of(context)!.share,
                ),
                action: ScheduleAction.share,
                onPressed: () => onSharePressed(context, state),
              ),
            ],
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
              schedule: null,
              onNextWeek: () => onNextWeek(context),
              onPreviousWeek: () => onPreviousWeek(context),
            );
          }

          if (currentWeek < 1) {
            return const SizedBox();
          }

          if (currentWeek > 52) {
            return null;
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
}

Future<void> waitReturnToHomeSchedule(
  Octopus octopus,
) async {
  await waitRouteChange(
    octopus,
    shouldStopListen: () {
      final lastNode = octopus.observer.value.children.last;

      return lastNode.name == Routes.home.name;
    },
  );
}

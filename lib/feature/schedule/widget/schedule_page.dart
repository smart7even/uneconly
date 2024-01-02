import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
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

/// {@template schedule_page}
/// SchedulePage widget
/// {@endtemplate}
class SchedulePage extends StatefulWidget {
  final ShortGroupInfo shortGroupInfo;

  /// {@macro schedule_page}
  const SchedulePage({
    super.key,
    required this.shortGroupInfo,
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

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en');
    // Initial state initialization

    scheduleBLoC = _initBloc(context);

    WidgetsBinding.instance.addObserver(this);
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
          week: _getCurrentWeek(),
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
    final dependenciesScope = context.read<DependenciesScope>();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  Future<void> onPageChanged(
    BuildContext context,
    int newIndex,
    int? week,
    Map<int, ScheduleDetails> data,
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
              AppRouter.navigate(
                context,
                (configuration) => AppRoutePath.select(
                  shortGroupInfo: ShortGroupInfo(
                    groupId: widget.shortGroupInfo.groupId,
                    groupName: widget.shortGroupInfo.groupName,
                  ),
                ),
              );
            },
          ),
          // ListTile for settings
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.settings,
            ),
            onTap: () {
              AppRouter.navigate(
                context,
                (configuration) => const AppRoutePath.settings(),
              );
            },
          ),
        ],
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
      drawer: _buildDrawer(
        context,
        state,
      ),
      appBar: AppBar(
        title: Text(title),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(
        //       right: 10,
        //     ),
        //     child: IconButton(
        //       onPressed: () {},
        //       icon: const Icon(
        //         Icons.edit,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (int newIndex) =>
            onPageChanged(context, newIndex, week, data),
        itemBuilder: (context, index) {
          debugPrint('index: ${index - initialPageIndex}');
          int? currentWeek;

          if (week != null) {
            currentWeek = week + index - initialPageIndex;
          }

          if (currentWeek == null) {
            return const ScheduleWidget(schedule: Schedule.empty());
          }

          if (currentWeek < 0 || currentWeek > 52) {
            return const ScheduleWidget(schedule: Schedule.empty());
          }

          return ScheduleWidget(schedule: data[currentWeek]?.schedule);
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

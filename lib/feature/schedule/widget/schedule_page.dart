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

/// {@template schedule_page}
/// SchedulePage widget
/// {@endtemplate}
class SchedulePage extends StatefulWidget {
  final int groupId;
  final String groupName;

  /// {@macro schedule_page}
  const SchedulePage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
} // SchedulePage

/// State for widget SchedulePage
class _SchedulePageState extends State<SchedulePage> {
  static const initialPageIndex = 4242;

  final controller = PageController(
    initialPage: initialPageIndex,
  );

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en');
    // Initial state initialization
  }

  @override
  void didUpdateWidget(SchedulePage oldWidget) {
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
            groupId: widget.groupId,
            week: newWeek,
          ),
        );
  }

  Widget _buildDrawer(BuildContext context) {
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
                  widget.groupName,
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
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ),
                ),
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
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: Text(widget.groupName),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    }

    String title = widget.groupName;

    if (selectedWeek != null) {
      title += ', ${AppLocalizations.of(context)!.week} $selectedWeek';

      if (week != null && week == selectedWeek) {
        title += ' (${AppLocalizations.of(context)!.now})';
      }
    }

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(title),
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
    return BlocProvider(
      create: (context) {
        final currentTime = DateTime.now();

        final dependenciesScope = context.read<DependenciesScope>();

        ScheduleNetworkDataProvider scheduleNetworkDataProvider =
            ScheduleNetworkDataProvider(
          dio: dependenciesScope.dio,
        );

        IScheduleLocalDataProvider localDataProvider =
            ScheduleLocalDataProvider(
          dependenciesScope.database,
        );

        ScheduleRepository repository = ScheduleRepository(
          networkDataProvider: scheduleNetworkDataProvider,
          localDataProvider: localDataProvider,
        );

        var bloc = ScheduleBLoC(repository: repository);
        bloc.add(
          ScheduleEvent.fetch(
            groupId: widget.groupId,
            week: getStudyWeekNumber(currentTime, currentTime),
          ),
        );

        return bloc;
      },
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

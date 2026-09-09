import 'dart:async';
import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/routing/routing_utils.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/data/schedule_calendar_data_provider.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_actions_popup.dart';
import 'package:uneconly/feature/schedule/widget/schedule_drawer.dart';
import 'package:uneconly/feature/schedule/widget/schedule_refresh_overlay.dart';
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
  final bool isHomePage;

  /// {@macro schedule_page}
  const SchedulePage({
    super.key,
    required this.scheduleInfo,
    required this.isViewMode,
    this.isHomePage = false,
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
  late final ScheduleNetworkDataProvider scheduleNetworkDataProvider;
  late final IScheduleRepository scheduleRepository;
  int? _academicYearStart;
  AppConfig _appConfig = const AppConfig.safeDefaults();

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
    unawaited(_bootstrapSchedule());
    unawaited(_refreshAppConfig());

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
    controller.dispose();
    scheduleBLoC.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Called when the application state changes

    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAppConfig());
      unawaited(_loadRecommendedSchedule(refresh: true));

      setState(() {
        log('app resumed');
      });
    }
  }

  int _getCurrentWeek() {
    final currentTime = DateTime.now();

    return getStudyWeekNumber(currentTime, currentTime);
  }

  DateTime _getCurrentPeriodStart() {
    final currentTime = DateTime.now();
    return getStartOfStudyWeek(_getCurrentWeek(), currentTime);
  }

  Future<void> _loadRecommendedSchedule({
    bool refresh = false,
    Schedule? alreadyRefreshing,
  }) async {
    int recommendedWeek;
    DateTime recommendedPeriodStart;
    int recommendedAcademicYearStart;

    try {
      final context = await scheduleNetworkDataProvider.fetchContext();
      recommendedWeek = context.recommended.week;
      recommendedPeriodStart = context.recommended.periodStart;
      recommendedAcademicYearStart = context.recommended.academicYearStart;
    } on Object catch (error, stackTrace) {
      // An older backend does not have /schedule/context. Retain the released
      // app's local calculation as a compatibility fallback.
      log('Schedule context is unavailable',
          error: error, stackTrace: stackTrace);
      recommendedWeek = _getCurrentWeek();
      recommendedPeriodStart = _getCurrentPeriodStart();
      recommendedAcademicYearStart = getAcademicYearStartForPeriod(
        recommendedPeriodStart,
        recommendedPeriodStart.add(const Duration(days: 6)),
      );
    }

    if (!mounted) {
      return;
    }

    final state = scheduleBLoC.state;
    final shouldRebase = state.currentWeek == null ||
        (refresh &&
            state.selectedWeek == state.currentWeek &&
            recommendedWeek != state.currentWeek);

    if (shouldRebase) {
      _academicYearStart = recommendedAcademicYearStart;
      if (controller.hasClients) {
        controller.jumpToPage(initialPageIndex);
      }
      scheduleBLoC.add(
        ScheduleEvent.fetch(
          week: recommendedWeek,
          academicYearStart: recommendedAcademicYearStart,
          setAsCurrent: true,
          info: widget.scheduleInfo,
        ),
      );
      return;
    }

    if (alreadyRefreshing != null &&
        recommendedWeek == alreadyRefreshing.week &&
        recommendedAcademicYearStart == alreadyRefreshing.academicYearStart) {
      return;
    }

    _academicYearStart ??= recommendedAcademicYearStart;
    final selectedWeek = state.selectedWeek ?? recommendedWeek;
    scheduleBLoC.add(
      ScheduleEvent.fetch(
        week: selectedWeek,
        academicYearStart: _academicYearStart,
        info: widget.scheduleInfo,
      ),
    );
  }

  Future<void> _bootstrapSchedule() async {
    final cached = await scheduleRepository.getClosestLocalSchedule(
      info: widget.scheduleInfo,
      date: DateTime.now(),
    );

    if (!mounted) {
      return;
    }

    Schedule? alreadyRefreshing;
    if (cached != null && scheduleBLoC.state.currentWeek == null) {
      final schedule = cached.schedule;
      alreadyRefreshing = schedule;
      _academicYearStart = schedule.academicYearStart;
      scheduleBLoC.add(
        ScheduleEvent.fetch(
          week: schedule.week,
          academicYearStart: schedule.academicYearStart,
          setAsCurrent: true,
          info: widget.scheduleInfo,
        ),
      );
    }

    // The server may recommend a newly published academic week that differs
    // from the nearest local period. Refresh that decision in the background;
    // cached content remains usable while this request is slow or unavailable.
    unawaited(
      _loadRecommendedSchedule(
        refresh: true,
        alreadyRefreshing: alreadyRefreshing,
      ),
    );
  }

  Future<void> _refreshAppConfig() async {
    AppConfig config;
    try {
      config = await scheduleNetworkDataProvider.fetchAppConfig();
    } on Object catch (error, stackTrace) {
      // Fail closed: an old or unavailable backend must not expose a broken map.
      log('App config is unavailable', error: error, stackTrace: stackTrace);
      config = const AppConfig.safeDefaults();
    }

    if (mounted && config != _appConfig) {
      setState(() => _appConfig = config);
    }
  }

  ScheduleBLoC _initBloc(BuildContext context) {
    final dependenciesScope = Dependencies.of(context);

    scheduleNetworkDataProvider = ScheduleNetworkDataProvider(
      dio: dependenciesScope.dio,
    );

    IScheduleLocalDataProvider localDataProvider = ScheduleLocalDataProvider(
      dependenciesScope.database,
    );

    IScheduleCalendarDataProvider calendarDataProvider =
        ScheduleCalendarDataProvider(
      deviceCalendarPlugin: DeviceCalendarPlugin(),
      lessonChoiceRepository: LessonChoiceRepository(
        dependenciesScope.sharedPreferences,
      ),
    );

    scheduleRepository = ScheduleRepository(
      networkDataProvider: scheduleNetworkDataProvider,
      localDataProvider: localDataProvider,
      calendarDataProvider: calendarDataProvider,
      settingsLocalDataProvider: dependenciesScope.settingsLocalDataProvider,
    );

    IGroupNetworkDataProvider groupNetworkDataProvider =
        GroupNetworkDataProvider(
      dio: dependenciesScope.dio,
    );

    IGroupRepository groupRepository = GroupRepository(
      networkDataProvider: groupNetworkDataProvider,
    );

    var bloc = ScheduleBLoC(
      repository: scheduleRepository,
      groupRepository: groupRepository,
      lessonChoiceRepository: LessonChoiceRepository(
        dependenciesScope.sharedPreferences,
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
          academicYearStart: _academicYearStart,
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

    final newWeek = scheduleWeekForPageIndex(
      pageIndex: newIndex,
      basePageIndex: initialPageIndex,
      baseWeek: week,
    );

    if (!isValidScheduleWeek(newWeek)) {
      final selectedWeek = scheduleBLoC.state.selectedWeek ?? week;
      final selectedIndex = pageIndexForScheduleWeek(
        week: selectedWeek,
        basePageIndex: initialPageIndex,
        baseWeek: week,
      );
      if (controller.hasClients) {
        unawaited(
          controller.animateToPage(
            selectedIndex,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          ),
        );
      }
      return;
    }

    unawaited(_refreshAppConfig());

    scheduleBLoC.add(
      ScheduleEvent.fetch(
        info: widget.scheduleInfo,
        week: newWeek,
        academicYearStart: _academicYearStart,
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

  void onUpdate(
    BuildContext context,
    ScheduleState state,
  ) {
    unawaited(_refreshAppConfig());
    unawaited(_loadRecommendedSchedule(refresh: true));
  }

  void onNextWeek(BuildContext context) {
    final currentPage = controller.page;
    final baseWeek = scheduleBLoC.state.currentWeek;

    if (currentPage == null || baseWeek == null) {
      return;
    }

    final newPage = currentPage.round() + 1;
    final newWeek = scheduleWeekForPageIndex(
      pageIndex: newPage,
      basePageIndex: initialPageIndex,
      baseWeek: baseWeek,
    );
    if (!isValidScheduleWeek(newWeek)) {
      return;
    }

    controller.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void onPreviousWeek(BuildContext context) {
    final currentPage = controller.page;
    final baseWeek = scheduleBLoC.state.currentWeek;

    if (currentPage == null || baseWeek == null) {
      return;
    }

    final newPage = currentPage.round() - 1;
    final newWeek = scheduleWeekForPageIndex(
      pageIndex: newPage,
      basePageIndex: initialPageIndex,
      baseWeek: baseWeek,
    );
    if (!isValidScheduleWeek(newWeek)) {
      return;
    }

    controller.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> onFavoritePressed(
    BuildContext context,
    ScheduleState state,
  ) async {
    final wasFavorite = isFavorite;
    setState(() => isFavorite = !wasFavorite);

    await state.scheduleInfo?.map(
      group: (group) async {
        final groupModel = Group(
          id: group.shortGroupInfo.groupId,
          name: group.shortGroupInfo.groupName ?? '',
          facultyId: 0,
          course: 0,
        );

        if (isFavorite) {
          await Dependencies.of(context)
              .settingsRepository
              .addGroupToFavorites(groupModel);
        } else {
          await Dependencies.of(context)
              .settingsRepository
              .removeGroupFromFavorites(groupModel);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? context.string.addToFavorites
                  : context.string.removeFromFavorites,
            ),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () async {
                setState(() => isFavorite = wasFavorite);
                if (wasFavorite) {
                  await Dependencies.of(context)
                      .settingsRepository
                      .addGroupToFavorites(groupModel);
                } else {
                  await Dependencies.of(context)
                      .settingsRepository
                      .removeGroupFromFavorites(groupModel);
                }
              },
            ),
          ),
        );
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
          await SharePlus.instance.share(
            ShareParams(
              text: content,
            ),
          );

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
    ScheduleState state, {
    bool hasNetworkError = false,
  }) {
    int? week = state.currentWeek;
    int? selectedWeek = state.selectedWeek;
    Map<int, ScheduleDetails> data = state.data;
    String message = state.message;
    final selectedDetails = selectedWeek == null ? null : data[selectedWeek];

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

    final scheduleTitle = state.scheduleInfo?.title ?? '';
    String weekSubtitle = '';

    if (selectedWeek != null) {
      final selectedSchedule = data[selectedWeek]?.schedule;
      weekSubtitle = selectedSchedule == null
          ? '${context.string.week} $selectedWeek'
          : _weekRange(
              selectedSchedule.periodStart, selectedSchedule.periodEnd);
      if (week != null && week == selectedWeek) weekSubtitle += ' · эта неделя';
    }

    final isGroupSchedule = widget.scheduleInfo.map(
      group: (group) => true,
      professor: (professor) => false,
    );
    if (!isGroupSchedule && weekSubtitle.isNotEmpty) {
      weekSubtitle = 'Преподаватель · $weekSubtitle';
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.palette.surface,
      drawer: !widget.isViewMode
          ? _buildDrawer(
              context,
              state,
            )
          : null,
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: context.palette.surface,
        foregroundColor: context.palette.ink,
        centerTitle: false,
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scheduleTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (weekSubtitle.isNotEmpty)
              Text(
                weekSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.palette.muted,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: context.palette.hairline,
          ),
        ),
        actions: [
          if (!widget.isViewMode)
            IconButton(
              onPressed: () => onSharePressed(context, state),
              tooltip: context.string.share,
              icon: const Icon(Icons.ios_share_outlined),
            )
          else
            ScheduleActionsPopup(
              actions: [
                if (widget.isViewMode && isGroupSchedule)
                  ScheduleActionConfig(
                    Text(
                      isFavorite
                          ? context.string.removeFromFavorites
                          : context.string.addToFavorites,
                    ),
                    action: ScheduleAction.favorite,
                    onPressed: () => onFavoritePressed(context, state),
                  ),
                ScheduleActionConfig(
                  Text(
                    context.string.share,
                  ),
                  action: ScheduleAction.share,
                  onPressed: () => onSharePressed(context, state),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (hasNetworkError)
            _OfflineBanner(
                onRetry: () => _loadRecommendedSchedule(refresh: true)),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    key: const ValueKey('schedule-week-page-view'),
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    physics: week == null
                        ? const PageScrollPhysics()
                        : WeekPageScrollPhysics(
                            minPageIndex: pageIndexForScheduleWeek(
                              week: minScheduleWeek,
                              basePageIndex: initialPageIndex,
                              baseWeek: week,
                            ),
                            maxPageIndex: pageIndexForScheduleWeek(
                              week: maxScheduleWeek,
                              basePageIndex: initialPageIndex,
                              baseWeek: week,
                            ),
                          ),
                    onPageChanged: (int newIndex) =>
                        onPageChanged(context, newIndex, week),
                    itemBuilder: (context, index) {
                      int? currentWeek;

                      if (week != null) {
                        currentWeek = scheduleWeekForPageIndex(
                          pageIndex: index,
                          basePageIndex: initialPageIndex,
                          baseWeek: week,
                        );
                      }

                      if (currentWeek == null) {
                        return ScheduleWidget(
                          schedule: null,
                          onNextWeek: () => onNextWeek(context),
                          onPreviousWeek: () => onPreviousWeek(context),
                          showCalendarBlock: widget.isHomePage,
                          onUpdate: () => onUpdate(
                            context,
                            state,
                          ),
                          appConfig: _appConfig,
                        );
                      }

                      if (currentWeek < minScheduleWeek) {
                        return const SizedBox();
                      }

                      if (currentWeek > maxScheduleWeek) {
                        return const SizedBox();
                      }

                      return ScheduleWidget(
                        schedule: data[currentWeek]?.schedule,
                        onNextWeek: () => onNextWeek(context),
                        onPreviousWeek: () => onPreviousWeek(context),
                        showCalendarBlock: widget.isHomePage,
                        onUpdate: () => onUpdate(
                          context,
                          state,
                        ),
                        appConfig: _appConfig,
                      );
                    },
                  ),
                ),
                ScheduleRefreshOverlay(
                  isVisible: state.isProcessing && selectedDetails != null,
                  details: selectedDetails,
                ),
              ],
            ),
          ),
        ],
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
              if (state.hasData) {
                return _buildPageView(
                  context,
                  state,
                  hasNetworkError: true,
                );
              }
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    context.string.scheduleError,
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off_outlined,
                            size: 42, color: context.palette.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Не удалось загрузить расписание',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Проверьте интернет-соединение и попробуйте ещё раз.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.palette.muted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _loadRecommendedSchedule(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: Text(context.string.tryAgain),
                        ),
                      ],
                    ),
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

String _weekRange(DateTime start, DateTime end) {
  if (start.month == end.month) {
    return '${start.day}–${end.day} ${_monthInDate(end)}';
  }
  return '${start.day} ${DateFormat('MMM', 'ru').format(start)} – '
      '${end.day} ${DateFormat('MMM', 'ru').format(end)}';
}

String _monthInDate(DateTime date) =>
    DateFormat('d MMMM', 'ru').format(date).replaceFirst('${date.day} ', '');

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.nestedSurface,
      child: InkWell(
        onTap: onRetry,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 18, color: context.palette.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Нет связи · показана сохранённая копия',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text('Обновить',
                  style: TextStyle(
                    color: context.palette.accent,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class WeekPageScrollPhysics extends PageScrollPhysics {
  const WeekPageScrollPhysics({
    required this.minPageIndex,
    required this.maxPageIndex,
    super.parent,
  });

  final int minPageIndex;
  final int maxPageIndex;

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final minPixels = minPageIndex * position.viewportDimension;
    final maxPixels = maxPageIndex * position.viewportDimension;

    if (value < minPixels) {
      return value - minPixels;
    }
    if (value > maxPixels) {
      return value - maxPixels;
    }
    return super.applyBoundaryConditions(position, value);
  }

  @override
  WeekPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      WeekPageScrollPhysics(
        minPageIndex: minPageIndex,
        maxPageIndex: maxPageIndex,
        parent: buildParent(ancestor),
      );
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

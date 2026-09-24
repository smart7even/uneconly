import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:octopus/octopus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';
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
import 'package:uneconly/feature/schedule/domain/schedule_share_document.dart';
import 'package:uneconly/feature/schedule/domain/schedule_share_image_renderer.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_actions_popup.dart';
import 'package:uneconly/feature/schedule/widget/schedule_drawer.dart';
import 'package:uneconly/feature/schedule/widget/schedule_refresh_overlay.dart';
import 'package:uneconly/feature/schedule/widget/schedule_week_navigation.dart';
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

  final controller = PageController(initialPage: initialPageIndex);
  int _lastPageIndex = initialPageIndex;
  ScheduleWeekChangeSource? _pendingWeekChangeSource;
  int _weekNavigationIntent = 0;

  late final ScheduleBLoC scheduleBLoC;
  late final ScheduleNetworkDataProvider scheduleNetworkDataProvider;
  late final IScheduleRepository scheduleRepository;
  int? _academicYearStart;
  AppConfig _appConfig = const AppConfig.safeDefaults();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Group> favoriteGroups = [];
  bool isFavorite = false;

  Timer? _rebuildTimer;
  bool _reviewQualificationScheduled = false;
  bool _sharing = false;

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

    dependenciesScope.settingsRepository.getFavoriteGroups().then((value) {
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
    });

    _rebuildTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (context.mounted) {
        setState(() {
          log('rebuild');
        });
      }
    });
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
      log(
        'Schedule context is unavailable',
        error: error,
        stackTrace: stackTrace,
      );
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
    final shouldRebase =
        state.currentWeek == null ||
        (refresh &&
            state.selectedWeek == state.currentWeek &&
            recommendedWeek != state.currentWeek);

    if (shouldRebase) {
      _academicYearStart = recommendedAcademicYearStart;
      if (controller.hasClients) {
        _pendingWeekChangeSource = null;
        _lastPageIndex = initialPageIndex;
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
        GroupNetworkDataProvider(dio: dependenciesScope.dio);

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

    final previousIndex = _lastPageIndex;
    _lastPageIndex = newIndex;
    final source = _pendingWeekChangeSource;
    _pendingWeekChangeSource = null;

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

    if (source != null && previousIndex != newIndex) {
      final group = widget.scheduleInfo.map(
        group: (value) => value.shortGroupInfo,
        professor: (_) => null,
      );
      unawaited(
        Dependencies.of(context).analyticsRepository.logScheduleWeekChange(
          source: source,
          direction: newIndex > previousIndex
              ? ScheduleWeekChangeDirection.next
              : ScheduleWeekChangeDirection.previous,
          surface: widget.isHomePage
              ? ScheduleSurface.home
              : ScheduleSurface.viewed,
          scope: group == null ? ScheduleScope.professor : ScheduleScope.group,
          groupId: group?.groupId,
          groupName: group?.groupName,
        ),
      );
    }

    unawaited(_refreshAppConfig());

    scheduleBLoC.add(
      ScheduleEvent.fetch(
        info: widget.scheduleInfo,
        week: newWeek,
        academicYearStart: _academicYearStart,
      ),
    );

    context.octopus.setArguments((args) {
      args['week'] = newWeek.toString();
    });
  }

  Future<void> _onFavoriteGroupsRefresh() async {
    final dependencies = Dependencies.of(context);

    final value = await dependencies.settingsRepository.getFavoriteGroups();

    setState(() {
      favoriteGroups.clear();
      favoriteGroups.addAll(value);
    });
  }

  Widget _buildDrawer(BuildContext context, ScheduleState state) {
    return ScheduleDrawer(
      favoriteGroups: favoriteGroups,
      onFavoriteGroupsRefresh: _onFavoriteGroupsRefresh,
    );
  }

  void onUpdate(BuildContext context, ScheduleState state) {
    unawaited(_refreshAppConfig());
    unawaited(_loadRecommendedSchedule(refresh: true));
  }

  void _animateWeek(int offset) {
    final currentPage = controller.page;
    final baseWeek = scheduleBLoC.state.currentWeek;

    if (currentPage == null || baseWeek == null) {
      return;
    }

    final newPage = currentPage.round() + offset;
    final newWeek = scheduleWeekForPageIndex(
      pageIndex: newPage,
      basePageIndex: initialPageIndex,
      baseWeek: baseWeek,
    );
    if (!isValidScheduleWeek(newWeek)) {
      return;
    }

    _pendingWeekChangeSource = ScheduleWeekChangeSource.button;
    final intent = ++_weekNavigationIntent;
    unawaited(
      controller
          .animateToPage(
            newPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          )
          .whenComplete(() {
            if (_weekNavigationIntent == intent) {
              _pendingWeekChangeSource = null;
            }
          }),
    );
  }

  void onNextWeek() => _animateWeek(1);

  void onPreviousWeek() => _animateWeek(-1);

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
          await Dependencies.of(
            context,
          ).settingsRepository.addGroupToFavorites(groupModel);
        } else {
          await Dependencies.of(
            context,
          ).settingsRepository.removeGroupFromFavorites(groupModel);
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
                  await Dependencies.of(
                    context,
                  ).settingsRepository.addGroupToFavorites(groupModel);
                } else {
                  await Dependencies.of(
                    context,
                  ).settingsRepository.removeGroupFromFavorites(groupModel);
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

  Future<void> onSharePressed(BuildContext context, ScheduleState state) async {
    if (_sharing) return;
    final details = state.getSelectedScheduleDetails();
    if (details == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.string.shareNoSchedule)));
      return;
    }

    final document = ScheduleShareDocument.fromSchedule(
      details.schedule,
      title: state.scheduleInfo?.title ?? '',
      choiceRepository: LessonChoiceRepository(
        Dependencies.of(context).sharedPreferences,
      ),
      updatedAt: details.updatedAt,
    );
    final analytics = Dependencies.of(context).analyticsRepository;
    final surface = widget.isHomePage
        ? ScheduleSurface.home
        : ScheduleSurface.viewed;
    final group = details.schedule.info.map(
      group: (value) => value.shortGroupInfo,
      professor: (_) => null,
    );
    final scope = group == null ? ScheduleScope.professor : ScheduleScope.group;
    void track(
      ScheduleShareStage stage, {
      ScheduleShareFormat? format,
      ScheduleShareResult? result,
    }) => unawaited(
      analytics.logScheduleShare(
        stage: stage,
        surface: surface,
        scope: scope,
        groupId: group?.groupId,
        groupName: group?.groupName,
        format: format,
        result: result,
      ),
    );

    track(ScheduleShareStage.chooserOpened);
    final format = await showModalBottomSheet<ScheduleShareFormat>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                context.string.shareSchedule,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              key: const ValueKey('share-as-text'),
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(context.string.shareAsText),
              subtitle: Text(context.string.shareAsTextDescription),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ScheduleShareFormat.text),
            ),
            ListTile(
              key: const ValueKey('share-as-image'),
              leading: const Icon(Icons.image_outlined),
              title: Text(context.string.shareAsImage),
              subtitle: Text(context.string.shareAsImageDescription),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ScheduleShareFormat.image),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (format == null) {
      track(ScheduleShareStage.chooserDismissed);
      return;
    }
    track(ScheduleShareStage.formatSelected, format: format);

    setState(() => _sharing = true);
    try {
      if (format == ScheduleShareFormat.text) {
        track(ScheduleShareStage.sheetOpened, format: format);
        final result = await SharePlus.instance.share(
          ShareParams(
            text: document.toPlainText(),
            subject: '${document.title} · ${document.periodLabel}',
            sharePositionOrigin: _shareOrigin(this.context),
          ),
        );
        track(
          ScheduleShareStage.completed,
          format: format,
          result: _shareResult(result.status),
        );
      } else {
        final image = await ScheduleShareImageRenderer().render(document);
        if (!mounted) return;
        final confirmed = await _previewShareImage(this.context, image);
        if (!mounted) return;
        if (!confirmed) {
          track(ScheduleShareStage.previewDismissed, format: format);
          return;
        }
        track(ScheduleShareStage.sheetOpened, format: format);
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(image, mimeType: 'image/png')],
            fileNameOverrides: [
              'uneconly_week_${document.week}_'
                  '${document.periodStart.year}_'
                  '${document.periodStart.month}_'
                  '${document.periodStart.day}.png',
            ],
            subject: '${document.title} · ${document.periodLabel}',
            sharePositionOrigin: _shareOrigin(this.context),
          ),
        );
        track(
          ScheduleShareStage.completed,
          format: format,
          result: _shareResult(result.status),
        );
      }
    } on Object catch (error, stackTrace) {
      log('Schedule sharing failed', error: error, stackTrace: stackTrace);
      if (mounted) {
        track(ScheduleShareStage.failed, format: format);
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text(this.context.string.shareFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  ScheduleShareResult _shareResult(ShareResultStatus status) =>
      switch (status) {
        ShareResultStatus.success => ScheduleShareResult.success,
        ShareResultStatus.dismissed => ScheduleShareResult.dismissed,
        ShareResultStatus.unavailable => ScheduleShareResult.unavailable,
      };

  Rect _shareOrigin(BuildContext context) {
    final box = Overlay.of(context).context.findRenderObject() as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    return Rect.fromCenter(center: center, width: 1, height: 1);
  }

  Future<bool> _previewShareImage(
    BuildContext context,
    Uint8List image,
  ) async =>
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.85,
            child: Column(
              children: [
                Text(
                  context.string.shareImagePreview,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Image.memory(
                      image,
                      key: const ValueKey('share-image-preview'),
                      width: MediaQuery.sizeOf(sheetContext).width - 32,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('confirm-share-image'),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      icon: const Icon(Icons.ios_share_outlined),
                      label: Text(context.string.shareImageNow),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;

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

    if (widget.isHomePage &&
        selectedDetails?.schedule.daySchedules.isNotEmpty == true &&
        !_reviewQualificationScheduled) {
      _reviewQualificationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          Dependencies.of(
            context,
          ).appReviewService.registerSuccessfulScheduleSession(),
        );
      });
    }

    if (week == 0) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(context, state),
        appBar: AppBar(title: Text(state.scheduleInfo?.title ?? '')),
        body: Center(child: Text(message)),
      );
    }

    final scheduleTitle = state.scheduleInfo?.title ?? '';
    final isGroupSchedule = widget.scheduleInfo.map(
      group: (group) => true,
      professor: (professor) => false,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.palette.surface,
      drawer: !widget.isViewMode ? _buildDrawer(context, state) : null,
      appBar: AppBar(
        toolbarHeight: 62,
        elevation: 0,
        backgroundColor: context.palette.surface,
        foregroundColor: context.palette.ink,
        centerTitle: false,
        titleSpacing: 4,
        title: ScheduleWeekAppBarTitle(
          title: scheduleTitle,
          selectedWeek: selectedWeek,
          schedule: selectedDetails?.schedule,
        ),
        actions: [
          if (!widget.isViewMode)
            IconButton(
              onPressed: _sharing ? null : () => onSharePressed(context, state),
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
                  Text(context.string.share),
                  action: ScheduleAction.share,
                  onPressed: () => onSharePressed(context, state),
                ),
              ],
            ),
        ],
      ),
      // A contextual control above the system gesture area. The future app
      // destination bar belongs to HomePage, not to this week switcher.
      bottomNavigationBar: SafeArea(
        top: false,
        child: ScheduleWeekNavigation(
          selectedWeek: selectedWeek,
          currentWeek: week,
          schedule: selectedDetails?.schedule,
          onPrevious: onPreviousWeek,
          onNext: onNextWeek,
        ),
      ),
      body: Column(
        children: [
          if (hasNetworkError)
            _OfflineBanner(
              onRetry: () => _loadRecommendedSchedule(refresh: true),
            ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.depth != 0 ||
                          notification.metrics.axis != Axis.horizontal) {
                        return false;
                      }
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        _weekNavigationIntent++;
                        _pendingWeekChangeSource =
                            ScheduleWeekChangeSource.swipe;
                      } else if (notification is ScrollEndNotification) {
                        _pendingWeekChangeSource = null;
                      }
                      return false;
                    },
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
                            showCalendarBlock: widget.isHomePage,
                            onUpdate: () => onUpdate(context, state),
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
                          showCalendarBlock: widget.isHomePage,
                          onUpdate: () => onUpdate(context, state),
                          appConfig: _appConfig,
                        );
                      },
                    ),
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
            idle: (state) => _buildPageView(context, state),
            processing: (state) => _buildPageView(context, state),
            successful: (state) => _buildPageView(context, state),
            error: (state) {
              if (state.hasData) {
                return _buildPageView(context, state, hasNetworkError: true);
              }
              return Scaffold(
                appBar: AppBar(title: Text(context.string.scheduleError)),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 42,
                          color: context.palette.muted,
                        ),
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
              Icon(
                Icons.cloud_off_outlined,
                size: 18,
                color: context.palette.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Нет связи · показана сохранённая копия',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                'Обновить',
                style: TextStyle(
                  color: context.palette.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
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

Future<void> waitReturnToHomeSchedule(Octopus octopus) async {
  await waitRouteChange(
    octopus,
    shouldStopListen: () {
      final lastNode = octopus.observer.value.children.last;

      return lastNode.name == Routes.home.name;
    },
  );
}

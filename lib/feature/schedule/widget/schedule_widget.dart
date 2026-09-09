import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/calendar/calendar_block.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/lesson_tile.dart';
import 'package:uneconly/feature/schedule/widget/schedule_refresh_overlay.dart';
import 'package:uneconly/feature/schedule/widget/schedule_widget_content.dart';

/// {@template schedule_widget}
/// ScheduleWidget widget
/// {@endtemplate}
class ScheduleWidget extends StatefulWidget {
  final Schedule? schedule;
  final VoidCallback? onNextWeek;
  final VoidCallback? onPreviousWeek;
  final bool showCalendarBlock;
  final VoidCallback onUpdate;
  final AppConfig appConfig;

  /// {@macro schedule_widget}
  const ScheduleWidget({
    super.key,
    required this.schedule,
    this.onNextWeek,
    this.onPreviousWeek,
    required this.showCalendarBlock,
    required this.onUpdate,
    required this.appConfig,
  });

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  List<Widget> _buildSchedule(BuildContext context) {
    List<Widget> slivers = [];

    final currentSchedule = widget.schedule;

    if (currentSchedule == null) {
      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(title: Text('${context.string.loadingSchedule}...')),
        ),
      );

      return slivers;
    }

    final today = DateTime.now();

    var dayIndex = 0;
    while (dayIndex < currentSchedule.daySchedules.length) {
      final daySchedule = currentSchedule.daySchedules[dayIndex];
      var emptyRunEnd = dayIndex;
      if (daySchedule.lessons.isEmpty &&
          calculateDifferenceInDays(daySchedule.day, today) != 0) {
        while (emptyRunEnd + 1 < currentSchedule.daySchedules.length) {
          final next = currentSchedule.daySchedules[emptyRunEnd + 1];
          if (next.lessons.isNotEmpty ||
              calculateDifferenceInDays(next.day, today) == 0) {
            break;
          }
          emptyRunEnd++;
        }
      }
      final combineAlternatives = currentSchedule.info.map(
        group: (_) => true,
        professor: (_) => false,
      );
      final clusters = clusterParallelLessons(
        daySchedule.lessons,
        combineAlternatives: combineAlternatives,
      );
      final difference = calculateDifferenceInDays(daySchedule.day, today);
      final sectionTitle = emptyRunEnd > dayIndex
          ? _emptyRangeTitle(
              daySchedule.day,
              currentSchedule.daySchedules[emptyRunEnd].day,
            )
          : _sectionTitle(context, daySchedule.day, difference);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.palette.hairline),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      sectionTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                        color: difference == 0
                            ? context.palette.accent
                            : context.palette.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _daySummary(context, clusters),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (daySchedule.lessons.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    child: Text(
                      '—',
                      style: TextStyle(color: context.palette.hairline),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      emptyRunEnd > dayIndex
                          ? 'Свободные дни'
                          : context.string.freeDay,
                      style: TextStyle(color: context.palette.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        final choiceRepository = LessonChoiceRepository(
          Dependencies.of(context).sharedPreferences,
        );
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final cluster = clusters[index];

              return Column(
                children: [
                  LessonTile(
                    cluster: cluster,
                    currentTime: today,
                    scheduleInfo: currentSchedule.info,
                    choiceRepository: choiceRepository,
                    onChoiceChanged: () => setState(() {}),
                    appConfig: widget.appConfig,
                  ),
                  if (index < clusters.length - 1)
                    Divider(
                      height: 1,
                      indent: 88,
                      endIndent: 20,
                      color: context.palette.hairline,
                    ),
                ],
              );
            }, childCount: clusters.length),
          ),
        );
      }

      // Check that day is the last day before new year
      if (daySchedule.day.month == 12 && daySchedule.day.day == 31) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ListTile(
                title: Text(
                  '${context.string.newYearCongratulation} 🎄',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      dayIndex = emptyRunEnd + 1;
    }

    slivers.add(
      SliverToBoxAdapter(
        child: ScheduleWidgetContent(
          child: _ScheduleActionSurface(
            icon: Icons.newspaper_outlined,
            title: 'Новости и ссылки',
            subtitle: 'Новости университета и полезные сервисы',
            onTap: () => context.octopus.push(Routes.tutorials),
          ),
        ),
      ),
    );

    if (widget.showCalendarBlock) {
      slivers.add(
        SliverToBoxAdapter(
          child: ScheduleWidgetContent(
            child: CalendarBlock(
              onChanged: (value) {
                if (value) {
                  widget.onUpdate();
                }
              },
            ),
          ),
        ),
      );
    }

    slivers.add(
      SliverToBoxAdapter(
        child: ScheduleWidgetContent(
          child: _WeekNavigation(
            schedule: currentSchedule,
            onPrevious: widget.onPreviousWeek,
            onNext: widget.onNextWeek,
          ),
        ),
      ),
    );

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height:
              MediaQuery.of(context).padding.bottom +
              scheduleRefreshOverlayClearance,
        ),
      ),
    );

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = widget.schedule;

    if (currentSchedule == null) {
      return const _ScheduleSkeleton();
    }

    if (currentSchedule.daySchedules.isEmpty) {
      final dateFormat = DateFormat('dd MMMM yyyy');
      final weekStart = dateFormat.format(currentSchedule.periodStart);
      final weekEnd = dateFormat.format(currentSchedule.periodEnd);

      return Padding(
        key: const ValueKey('schedule-unpublished'),
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          28 + scheduleRefreshOverlayClearance,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 46,
                color: context.palette.muted,
              ),
              const SizedBox(height: 16),
              Text(
                context.string.noSchedule,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$weekStart – $weekEnd',
                style: TextStyle(color: context.palette.muted),
              ),
              const SizedBox(height: 10),
              Text(
                _emptyWeekNavigationHint(context, currentSchedule.week),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.palette.muted),
              ),
              const SizedBox(height: 24),
              _WeekNavigation(
                schedule: currentSchedule,
                onPrevious: widget.onPreviousWeek,
                onNext: widget.onNextWeek,
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      key: const ValueKey('schedule-content'),
      slivers: _buildSchedule(context),
    );
  }
}

String _sectionTitle(BuildContext context, DateTime day, int difference) {
  final date = DateFormat('d MMMM', 'ru').format(day);
  final weekday = DateFormat('E', 'ru').format(day).replaceAll('.', '');
  final relative = switch (difference) {
    0 => context.string.today,
    1 => context.string.tomorrow,
    -1 => context.string.yesterday,
    _ => capitalize(DateFormat('EEEE', 'ru').format(day)),
  };
  return '$relative · $date, $weekday';
}

String _emptyWeekNavigationHint(BuildContext context, int week) {
  if (week <= minScheduleWeek) {
    return 'Свайпните влево, чтобы посмотреть следующую неделю.';
  }
  if (week >= maxScheduleWeek) {
    return 'Свайпните вправо, чтобы посмотреть предыдущую неделю.';
  }
  return context.string.noScheduleDescription;
}

String _emptyRangeTitle(DateTime first, DateTime last) {
  final firstWeekday = capitalize(DateFormat('EEEE', 'ru').format(first));
  final lastWeekday = DateFormat('EEEE', 'ru').format(last);
  if (first.month == last.month) {
    return '$firstWeekday–$lastWeekday · ${first.day}–${last.day} '
        '${_monthInDate(last)}';
  }
  return '$firstWeekday–$lastWeekday · '
      '${DateFormat('d MMM', 'ru').format(first)}–'
      '${DateFormat('d MMM', 'ru').format(last)}';
}

String _monthInDate(DateTime date) =>
    DateFormat('d MMMM', 'ru').format(date).replaceFirst('${date.day} ', '');

class _ScheduleActionSurface extends StatelessWidget {
  const _ScheduleActionSurface({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.palette.nestedSurface,
    borderRadius: BorderRadius.circular(16),
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: context.palette.muted),
      onTap: onTap,
    ),
  );
}

class _WeekNavigation extends StatelessWidget {
  const _WeekNavigation({
    required this.schedule,
    required this.onPrevious,
    required this.onNext,
  });

  final Schedule schedule;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final previous = schedule.week > minScheduleWeek
        ? schedulePeriodStartForWeek(
            week: schedule.week - 1,
            academicYearStart: schedule.academicYearStart,
          )
        : schedule.periodStart;
    final next = schedule.week < maxScheduleWeek
        ? schedulePeriodStartForWeek(
            week: schedule.week + 1,
            academicYearStart: schedule.academicYearStart,
          )
        : schedule.periodStart;
    return Row(
      key: const ValueKey('week-navigation'),
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: schedule.week > minScheduleWeek ? onPrevious : null,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(DateFormat('d MMM', 'ru').format(previous)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: schedule.week < maxScheduleWeek ? onNext : null,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(DateFormat('d MMM', 'ru').format(next)),
          ),
        ),
      ],
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: const ValueKey('schedule-loading'),
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
    itemCount: 8,
    itemBuilder: (_, index) => Container(
      height: index % 3 == 0 ? 24 : 68,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.palette.nestedSurface,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

String _daySummary(BuildContext context, List<LessonCluster> clusters) {
  if (clusters.isEmpty) return context.string.lessonsCount(0);
  final first = clusters.first.lesson;
  final last = clusters.last.lesson;
  return '${context.string.lessonsCount(clusters.length)} · '
      '${DateFormat('HH:mm').format(first.start)}–'
      '${DateFormat('HH:mm').format(last.end)}';
}

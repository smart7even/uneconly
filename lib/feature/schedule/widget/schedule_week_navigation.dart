import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

class ScheduleWeekNavigation extends StatelessWidget {
  const ScheduleWeekNavigation({
    super.key,
    required this.selectedWeek,
    required this.currentWeek,
    required this.schedule,
    required this.onPrevious,
    required this.onNext,
  });

  final int? selectedWeek;
  final int? currentWeek;
  final Schedule? schedule;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final week = selectedWeek;
    final canGoPrevious = week != null && week > minScheduleWeek;
    final canGoNext = week != null && week < maxScheduleWeek;
    final primaryLabel = schedule == null
        ? week == null
              ? 'Определяем текущую неделю…'
              : 'Неделя $week'
        : formatSchedulePeriod(schedule!.periodStart, schedule!.periodEnd);
    final secondaryLabel = week == null
        ? 'Расписание'
        : [
            'Неделя $week',
            week.isOdd ? 'нечётная' : 'чётная',
            if (week == currentWeek) 'эта неделя',
          ].join(' · ');

    return Material(
      key: const ValueKey('week-navigation'),
      color: context.palette.surface,
      child: Container(
        height: 62,
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.palette.hairline)),
        ),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: Row(
            children: [
              _WeekArrowButton(
                key: const ValueKey('previous-week-button'),
                tooltip: week == null
                    ? 'Предыдущая неделя'
                    : 'Предыдущая неделя, ${week - 1}',
                icon: Icons.chevron_left_rounded,
                onPressed: canGoPrevious ? onPrevious : null,
              ),
              Expanded(
                child: Semantics(
                  container: true,
                  label: '$primaryLabel. $secondaryLabel',
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          primaryLabel,
                          key: const ValueKey('week-period-label'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          secondaryLabel,
                          key: const ValueKey('week-context-label'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.1,
                            color: context.palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _WeekArrowButton(
                key: const ValueKey('next-week-button'),
                tooltip: week == null
                    ? 'Следующая неделя'
                    : 'Следующая неделя, ${week + 1}',
                icon: Icons.chevron_right_rounded,
                onPressed: canGoNext ? onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekArrowButton extends StatelessWidget {
  const _WeekArrowButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 28),
    style: IconButton.styleFrom(
      minimumSize: const Size.square(46),
      maximumSize: const Size.square(46),
      backgroundColor: context.palette.nestedSurface,
      foregroundColor: context.palette.ink,
      disabledBackgroundColor: context.palette.nestedSurface,
      disabledForegroundColor: context.palette.hairline,
    ),
  );
}

String formatSchedulePeriod(DateTime start, DateTime end) {
  if (start.month == end.month && start.year == end.year) {
    return '${start.day}–${end.day} ${_monthInDate(end)}';
  }
  return '${start.day} ${DateFormat('MMM', 'ru').format(start)} – '
      '${end.day} ${DateFormat('MMM', 'ru').format(end)}';
}

String _monthInDate(DateTime date) =>
    DateFormat('d MMMM', 'ru').format(date).replaceFirst('${date.day} ', '');

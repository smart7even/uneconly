import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/widget/lesson_tile.dart';

/// {@template schedule_widget}
/// ScheduleWidget widget
/// {@endtemplate}
class ScheduleWidget extends StatelessWidget {
  final Schedule? schedule;
  final VoidCallback? onNextWeek;
  final VoidCallback? onPreviousWeek;

  /// {@macro schedule_widget}
  const ScheduleWidget({
    super.key,
    required this.schedule,
    this.onNextWeek,
    this.onPreviousWeek,
  });

  List<Widget> _buildSchedule(BuildContext context) {
    List<Widget> slivers = [];

    final currentSchedule = schedule;

    if (currentSchedule == null) {
      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(
            title: Text('${AppLocalizations.of(context)!.loadingSchedule}...'),
          ),
        ),
      );

      return slivers;
    }

    for (var daySchedule in currentSchedule.daySchedules) {
      String sectionTitle = capitalize(
        DateFormat('EEEE, d MMMM', 'ru').format(
          daySchedule.day,
        ),
      );

      final today = DateTime.now();
      final difference = calculateDifferenceInDays(daySchedule.day, today);

      if (difference == 0) {
        sectionTitle = '${AppLocalizations.of(context)!.today}, $sectionTitle';
      } else if (difference == 1) {
        sectionTitle =
            '${AppLocalizations.of(context)!.tomorrow}, $sectionTitle';
      } else if (difference == -1) {
        sectionTitle =
            '${AppLocalizations.of(context)!.yesterday}, $sectionTitle';
      }

      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              sectionTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );

      if (daySchedule.lessons.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.noLessons),
            ),
          ),
        );
      } else {
        slivers.add(SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final lesson = daySchedule.lessons[index];

              return LessonTile(lesson: lesson);
            },
            childCount: daySchedule.lessons.length,
          ),
        ));
      }

      // Check that day is the last day before new year
      if (daySchedule.day.month == 12 && daySchedule.day.day == 31) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ListTile(
                title: Text(
                  '${AppLocalizations.of(context)!.newYearCongratulation} 🎄',
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
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = schedule;

    if (currentSchedule == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.schedule),
      );
    }

    if (currentSchedule.daySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.noSchedule),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.noScheduleDescription,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onPreviousWeek?.call();
                  },
                  child: const Icon(
                    Icons.arrow_left,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    onNextWeek?.call();
                  },
                  child: const Icon(
                    Icons.arrow_right,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: _buildSchedule(context),
    );
  }
}

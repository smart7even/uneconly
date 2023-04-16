import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

/// {@template schedule_widget}
/// ScheduleWidget widget
/// {@endtemplate}
class ScheduleWidget extends StatelessWidget {
  final Schedule? schedule;

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
              String subtitle = '';

              String? professor = lesson.professor;

              if (professor != null) {
                subtitle = professor;
              }

              String location = lesson.location.replaceAll('\n', ' ').trim();

              subtitle = '$subtitle $location';

              return ListTile(
                title: Text(
                  lesson.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  subtitle,
                ),
                trailing: Text(
                  '${DateFormat('HH:mm').format(
                    lesson.start,
                  )} - ${DateFormat('HH:mm').format(
                    lesson.end,
                  )}',
                ),
              );
            },
            childCount: daySchedule.lessons.length,
          ),
        ));
      }
    }

    return slivers;
  }

  /// {@macro schedule_widget}
  const ScheduleWidget({
    super.key,
    required this.schedule,
  });

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
        child: Text(AppLocalizations.of(context)!.noSchedule),
      );
    }

    return CustomScrollView(
      slivers: _buildSchedule(context),
    );
  }
} // ScheduleWidget

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        const SliverToBoxAdapter(
          child: ListTile(
            title: Text('Загружаем расписание...'),
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
        sectionTitle = 'Сегодня, $sectionTitle';
      } else if (difference == 1) {
        sectionTitle = 'Завтра, $sectionTitle';
      } else if (difference == -1) {
        sectionTitle = 'Вчера, $sectionTitle';
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
          const SliverToBoxAdapter(
            child: ListTile(
              title: Text('Нет пар'),
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
      return const Center(
        child: Text('Schedule'),
      );
    }

    if (currentSchedule.daySchedules.isEmpty) {
      return const Center(
        child: Text('Нет расписания'),
      );
    }

    return CustomScrollView(
      slivers: _buildSchedule(context),
    );
  }
} // ScheduleWidget

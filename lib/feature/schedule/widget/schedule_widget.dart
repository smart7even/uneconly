import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              capitalize(
                DateFormat('EEEE, d MMMM', 'ru').format(
                  daySchedule.day,
                ),
              ),
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
              return ListTile(
                title: Text(
                  daySchedule.lessons[index].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  daySchedule.lessons[index].professor ?? '-',
                ),
                trailing: Text(
                  '${DateFormat('HH:mm').format(
                    daySchedule.lessons[index].start,
                  )} - ${DateFormat('HH:mm').format(
                    daySchedule.lessons[index].end,
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/widget/lesson_big_tile.dart';

/// {@template day_schedule_widget}
/// DayScheduleWidget widget
/// {@endtemplate}
class DaySchedulePage extends StatelessWidget {
  final DaySchedule daySchedule;

  /// {@macro day_schedule_widget}
  const DaySchedulePage({super.key, required this.daySchedule});

  @override
  Widget build(BuildContext context) {
    final grouppedLessonsByTime = groupLessonsByTime(daySchedule.lessons);
    final overlappingLessons = grouppedLessonsByTime
        .where(
          (element) => element.length > 1,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          capitalize(
            DateFormat('EEEE, d MMMM', 'ru').format(
              daySchedule.day,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (overlappingLessons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Внимание! На это время назначено несколько пар',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: daySchedule.lessons.length,
              itemBuilder: (context, index) {
                return LessonBigTile(
                  lesson: daySchedule.lessons[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

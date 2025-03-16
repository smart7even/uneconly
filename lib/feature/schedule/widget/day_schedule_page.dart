import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/analytics/page_logging_wrapper.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/widget/lesson_big_tile.dart';

/// {@template day_schedule_widget}
/// DayScheduleWidget widget
/// {@endtemplate}
class DaySchedulePage extends StatelessWidget {
  final DaySchedule daySchedule;

  /// {@macro day_schedule_widget}
  const DaySchedulePage({super.key, required this.daySchedule});

  int getLessonNumber(List<List<Lesson>> grouppedLessonsByTime, Lesson lesson) {
    for (var i = 0; i < grouppedLessonsByTime.length; i++) {
      if (grouppedLessonsByTime[i].contains(lesson)) {
        return i + 1;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final grouppedLessonsByTime = groupLessonsByTime(daySchedule.lessons);
    final overlappingLessons = grouppedLessonsByTime
        .where(
          (element) => element.length > 1,
        )
        .toList();

    return PageLoggingWrapper(
      pageName: 'daySchedule',
      parameters: {
        'day': daySchedule.day.toIso8601String(),
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            capitalize(
              DateFormat('EEEE, d MMMM', 'ru').format(
                daySchedule.day,
              ),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              slivers: [
                if (daySchedule.lessons.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'На этот день нет пар 🍀',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (grouppedLessonsByTime.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Всего пар: ${grouppedLessonsByTime.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                // if (overlappingLessons.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.all(8),
                //     child: Text(
                //       'Внимание! На это время назначено несколько пар',
                //       style: TextStyle(
                //         color: Theme.of(context).colorScheme.error,
                //       ),
                //     ),
                //   ),
                if (daySchedule.lessons.isNotEmpty)
                  SliverList.builder(
                    itemCount: daySchedule.lessons.length,
                    itemBuilder: (context, index) {
                      return LessonBigTile(
                        lesson: daySchedule.lessons[index],
                        lessonNumber: getLessonNumber(
                          grouppedLessonsByTime,
                          daySchedule.lessons[index],
                        ),
                      );
                    },
                  ),
                // SliverToBoxAdapter(
                //   child: UneconlyDivKitView(
                //     data: {}
                //     ),
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

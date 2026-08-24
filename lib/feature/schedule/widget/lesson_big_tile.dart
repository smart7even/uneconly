import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/widget/lesson_badge.dart';
import 'package:uneconly/feature/schedule/widget/lesson_property.dart';

/// {@template lesson_big_tile}
/// LessonBigTile widget
/// {@endtemplate}
class LessonBigTile extends StatelessWidget {
  final Lesson lesson;
  final int lessonNumber;

  /// {@macro lesson_big_tile}
  const LessonBigTile({
    super.key,
    required this.lesson,
    required this.lessonNumber,
  });

  Widget _buildLessonProperty(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return LessonProperty(
      icon: icon,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final professor = lesson.professor;
    final professorId = lesson.professorId;
    final lessonType = lesson.lessonType;
    final group = lesson.group;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(
                    lesson.start,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: ' ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: DateFormat('HH:mm').format(
                        lesson.end,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // const SizedBox(
                //   height: 4,
                // ),
                _buildLessonProperty(
                  context,
                  Icons.location_on,
                  trimSeparators(cleanLessonLocation(lesson.location)),
                ),
                if (professor != null)
                  _buildLessonProperty(
                    context,
                    Icons.person,
                    professor,
                  ),
                if (group != null && group.isNotEmpty)
                  _buildLessonProperty(
                    context,
                    Icons.group,
                    group,
                  ),
                const SizedBox(
                  height: 4,
                ),
                SingleChildScrollView(
                  child: Row(
                    children: [
                      LessonBadge.text(
                        text: '$lessonNumber пара',
                      ),
                      if (lessonType != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: LessonBadge.text(
                            text: lessonType,
                            // onTap: () {},
                          ),
                        ),
                      if (professor != null && professorId != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: LessonBadge.icon(
                            icon: Icons.school,
                            onTap: () {
                              Octopus.of(context).push(
                                Routes.schedule,
                                arguments: {
                                  'professorId': professorId.toString(),
                                  'professorName': professor,
                                  'isViewMode': 'true',
                                },
                              );
                            },
                          ),
                        ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 4),
                      //   child: LessonBadge.icon(
                      //     icon: Icons.location_on,
                      //     onTap: () {},
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // LessonBigTile

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/widget/lesson_property.dart';

/// {@template lesson_big_tile}
/// LessonBigTile widget
/// {@endtemplate}
class LessonBigTile extends StatelessWidget {
  final Lesson lesson;

  /// {@macro lesson_big_tile}
  const LessonBigTile({
    super.key,
    required this.lesson,
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
                      text: 'A',
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
                const SizedBox(
                  height: 4,
                ),
                _buildLessonProperty(
                  context,
                  Icons.location_on,
                  trimSeparators(lesson.location),
                ),
                if (professor != null)
                  _buildLessonProperty(
                    context,
                    Icons.person,
                    professor,
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

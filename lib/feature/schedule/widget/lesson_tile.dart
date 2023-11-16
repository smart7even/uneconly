import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

class LessonTile extends StatefulWidget {
  const LessonTile({
    super.key,
    required this.lesson,
  });

  final Lesson lesson;

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String subtitle = '';

    String? professor = widget.lesson.professor;

    if (professor != null) {
      subtitle = professor;
    }

    String location = widget.lesson.location.replaceAll('\n', ' ').trim();

    subtitle = '$subtitle $location';

    return ListTile(
      title: Text(
        widget.lesson.name,
        maxLines: _isExpanded ? 5 : 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
      ),
      trailing: Text(
        '${DateFormat('HH:mm').format(
          widget.lesson.start,
        )} - ${DateFormat('HH:mm').format(
          widget.lesson.end,
        )}',
      ),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
    );
  }
} // LessonTile
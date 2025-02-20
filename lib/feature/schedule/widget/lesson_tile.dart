import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

class LessonTile extends StatefulWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.currentTime,
  });

  final Lesson lesson;
  final DateTime currentTime;

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile> {
  bool _isExpanded = false;

  String _appendWithSpace(String source, String item) {
    if (source.isEmpty) {
      return item;
    }

    return '$source $item';
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = '';

    String? professor = widget.lesson.professor;

    if (professor != null) {
      subtitle = professor;
    }

    String location = widget.lesson.location.replaceAll('\n', ' ').trim();

    subtitle = _appendWithSpace(subtitle, location);

    final isCurrentLesson = widget.currentTime.isAfter(widget.lesson.start) &&
        widget.currentTime.isBefore(widget.lesson.end);

    return ListTile(
      title: Text(
        widget.lesson.name,
        maxLines: _isExpanded ? 5 : 1,
        overflow: TextOverflow.ellipsis,
        // style: isCurrentLesson
        //     ? TextStyle(color: Theme.of(context).primaryColor)
        //     : const TextStyle(),
      ),
      subtitle: Text(
        subtitle,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        // rounded corners
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isCurrentLesson ? Theme.of(context).primaryColor : null,
        ),
        child: Text(
          '${DateFormat('HH:mm').format(
            widget.lesson.start,
          )} - ${DateFormat('HH:mm').format(
            widget.lesson.end,
          )}',
          style: TextStyle(
            color: isCurrentLesson
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
    );
  }
} // LessonTile